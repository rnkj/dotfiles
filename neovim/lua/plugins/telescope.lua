-- Fuzzy finder for files, grep, buffers, and more
return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("telescope").setup({})
    end,
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>",  desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>",    desc = "Buffers" },
    },
  },
}
