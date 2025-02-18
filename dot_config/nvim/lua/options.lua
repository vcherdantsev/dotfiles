-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, to help with jumping.
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
-- vim.opt.list = true
-- vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Включить отображение пробельных символов
vim.opt.list = true

-- Настроить символы для отображения пробелов и табуляций
vim.opt.listchars = {
    space = '·',  -- Символ для пробелов (точка)
    tab = '▸ ',   -- Символ для табуляции (стрелка)
    eol = '↴',    -- Символ для конца строки
    trail = '•',   -- Символ для пробелов в конце строки
    extends = '➔', -- Символ для длинных строк
    precedes = '➔', -- Символ для длинных строк
}

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- Включить expandtab
vim.opt.expandtab = true

-- Установить количество пробелов для табуляции
vim.opt.tabstop = 4      -- Количество пробелов, используемых для табуляции
vim.opt.shiftwidth = 4   -- Количество пробелов для автоматического отступа
vim.opt.softtabstop = 4  -- Количество пробелов, используемых при нажатии Tab

-- Отключаем netrw
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrw = 1