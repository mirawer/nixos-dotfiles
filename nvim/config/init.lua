-- ============================================================
-- Neovim config — bootstrap lazy.nvim
-- ============================================================

-- Zainstaluj lazy.nvim jesli nie istnieje
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Blad klonowania lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nNacisnij dowolny klawisz aby wyjsc..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================
-- Leader key
-- ============================================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ============================================================
-- Opcje edytora — dodaj wlasne w lua/config/options.lua
-- ============================================================
-- vim.opt.number = true
-- vim.opt.relativenumber = true
-- vim.opt.tabstop = 2
-- vim.opt.shiftwidth = 2
-- vim.opt.expandtab = true

-- ============================================================
-- Mapowania klawiszy — dodaj wlasne w lua/config/keymaps.lua
-- ============================================================
-- vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Zapisz" })

-- ============================================================
-- lazy.nvim — dodaj pluginy w lua/plugins/*.lua
-- ============================================================

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true

require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  install = { missing = true },
  checker = { enabled = true, notify = false },
})
