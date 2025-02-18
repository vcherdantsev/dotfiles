return {
    {
        "glacambre/firenvim",
        event = "VeryLazy",
        build = ":call firenvim#install(0)",
        config = function()
          -- configure firenvim for the browser
          if vim.g.started_by_firenvim then
            vim.cmd("source $HOME/.config/nvim/plugin/firenvim.vim")
          end
        end
    }
}