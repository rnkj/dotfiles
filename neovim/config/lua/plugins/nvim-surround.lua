-- Surround operations: add/change/delete brackets, quotes, and HTML-like tags
return {
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        surrounds = {
          -- Custom: angle bracket tag  <tag>...</tag>  triggered by "t"
          -- Default behavior: prompt for tag name, strips attributes on delete/change
        },
      })
    end,
    keys = {},
  },
}
