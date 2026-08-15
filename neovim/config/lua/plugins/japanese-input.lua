-- Automatically switch fcitx5 input method on mode change
return {
  {
    "h-hg/fcitx.nvim",
    event = { "InsertEnter", "CmdlineEnter" },
  }
}
