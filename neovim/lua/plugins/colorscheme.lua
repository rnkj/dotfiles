return {
  "rebelot/kanagawa.nvim",
  lazy = false,
  opts = {
    theme = "dragon",
    background = {
      dark = "dragon",
      light = "lotus",
    },
  },
  config = function(_, opts)
    require("kanagawa").setup(opts)
    vim.cmd("colorscheme kanagawa-dragon")
  end,
}
