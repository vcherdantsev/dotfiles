local Plugin = {'folke/which-key.nvim'}

Plugin.event = "VeryLazy"

-- Plugin.opts = {
--     -- Настройки по умолчанию
--     plugins = {
--         marks = true, -- показывать метки
--         registers = true, -- показывать регистры
--         spelling = {
--             enabled = true, -- показывать исправления
--             suggestions = 20, -- количество предложений
--         },
--     },
--     -- key_labels = {}, -- пользовательские метки для клавиш
--     icons = {
--         breadcrumb = "»", -- иконка для хлебных крошек
--         separator = "➜", -- иконка для разделителей
--         group = "+", -- иконка для групп
--     },
--     -- popup_mappings = {
--     --     scroll_down = '<c-d>', -- прокрутка вниз
--     --     scroll_up = '<c-u>', -- прокрутка вверх
--     -- },
--     win = {
--         border = "single", -- стиль границы окна
--         position = "bottom", -- позиция окна
--         margin = { 1, 1, 1, 1 }, -- отступы
--         padding = { 2, 2, 2, 2 }, -- внутренние отступы
--     },
--     layout = {
--         height = { min = 4, max = 25 }, -- высота окна
--         width = { min = 20, max = 50 }, -- ширина окна
--         spacing = 3, -- расстояние между элементами
--     },
--     -- ignore_missing = false, -- игнорировать отсутствующие ключи
--     -- hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "<CR>", "call" }, -- скрытые ключи
--     show_help = true, -- показывать помощь
-- }

-- function Plugin.init()
--   vim.keymap.set('n', '<leader>bc', '<cmd>Bdelete<CR>')
-- end

return Plugin