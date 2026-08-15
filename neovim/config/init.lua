require("config.lazy")

if vim.env.ZELLIJ then
  local function za(cmd)
    return function() vim.fn.system("zellij action " .. cmd) end
  end

  local function switch_mode(mode)
    vim.fn.system("zellij action switch-mode " .. mode)
  end

  local group = vim.api.nvim_create_augroup("ZellijFocus", { clear = true })

  -- Tab operation (C-t + ...)
  -- Switch to normal mode before tab navigation so Zellij unlocks when leaving the NeoVim tab
  local function za_leave(cmd)
    return function()
      switch_mode("normal")
      vim.fn.system("zellij action " .. cmd)
    end
  end

  -- vim.keymap.set('n', '<C-t>n', za("new-tab"),            { desc = "Zellij: New tab" })
  -- vim.keymap.set('n', '<C-t>x', za("close-tab"),          { desc = "Zellij: Close tab" })
  -- vim.keymap.set('n', '<C-t>l', za("go-to-next-tab"),     { desc = "Zellij: Go to next tab" })
  -- vim.keymap.set('n', '<C-t>h', za("go-to-previous-tab"), { desc = "Zellij: Go to previous tab" })
  -- for i = 1, 9 do
  --   vim.keymap.set('n', '<C-t>' .. i, za("go-to-tab-name " .. i), { desc = "Zellij: Go to tab No. " .. i })
  -- end
  vim.keymap.set('n', '<C-t>n', za_leave("new-tab"),            { desc = "Zellij: New tab" })
  vim.keymap.set('n', '<C-t>x', za_leave("close-tab"),          { desc = "Zellij: Close tab" })
  vim.keymap.set('n', '<C-t>l', za_leave("go-to-next-tab"),     { desc = "Zellij: Go to next tab" })
  vim.keymap.set('n', '<C-t>h', za_leave("go-to-previous-tab"), { desc = "Zellij: Go to previous tab" })
  for i = 1, 9 do
    vim.keymap.set('n', '<C-t>' .. i, za_leave("go-to-tab-name " .. i), { desc = "Zellij: Go to tab No. " .. i })
  end

  -- Pane operation (C-p + ...)
  vim.keymap.set('n', '<C-p>h', za("move-focus left"),            { desc = "Zellij: focus left" })
  vim.keymap.set('n', '<C-p>j', za("move-focus down"),            { desc = "Zellij: focus down" })
  vim.keymap.set('n', '<C-p>k', za("move-focus up"),              { desc = "Zellij: focus up" })
  vim.keymap.set('n', '<C-p>l', za("move-focus right"),           { desc = "Zellij: focus right" })
  vim.keymap.set('n', '<C-p>n', za("new-pane"),                   { desc = "Zellij: new pane" })
  vim.keymap.set('n', '<C-p>d', za("new-pane --direction down"),  { desc = "Zellij: split down" })
  vim.keymap.set('n', '<C-p>r', za("new-pane --direction right"), { desc = "Zellij: split right" })
  vim.keymap.set('n', '<C-p>x', za("close-pane"),                 { desc = "Zellij: close pane" })
  vim.keymap.set('n', '<C-p>f', za("toggle-fullscreen"),          { desc = "Zellij: toggle fullscreen" })
  vim.keymap.set('n', '<C-p>w', za("toggle-floating-panes"),      { desc = "Zellij: toggle floating" })
  vim.keymap.set('n', '<C-p>z', za("toggle-pane-frames"),         { desc = "Zellij: toggle frames" })

  -- Focus / Unfocus NeoVim Pane
  vim.api.nvim_create_autocmd({ "VimEnter", "FocusGained" }, {
    group = group,
    callback = function() switch_mode("locked") end,
  })
  vim.api.nvim_create_autocmd({ "VimLeave", "FocusLost" }, {
    group = group,
    callback = function() switch_mode("normal") end,
  })
end
