-- !!! DO NOT ADD DEVICE-SPECIFIC CONFIGURATION HERE — IT WILL INTERFERE WITH CROSS-DEVICE SYNC. USE init.local.lua INSTEAD. !!!

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local opt = vim.opt

-- Editing
opt.expandtab = true
opt.shiftwidth = 2
opt.softtabstop = 2
opt.tabstop = 2
opt.smartindent = true
opt.wrap = false
opt.linebreak = true
opt.breakindent = true

-- Interface
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.termguicolors = true
opt.showmode = false
opt.laststatus = 3
opt.scrolloff = 4
opt.sidescrolloff = 8
opt.list = true
opt.listchars = {
  tab = "» ",
  trail = "·",
  nbsp = "␣",
  extends = "›",
  precedes = "‹",
}

-- Search and completion
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true
opt.completeopt = { "menu", "menuone", "noselect" }

-- Behavior
opt.mouse = "a"
opt.confirm = true
opt.splitbelow = true
opt.splitright = true
opt.updatetime = 250
opt.timeoutlen = 300

-- Keep persistent undo files out of project directories.
local undo_dir = vim.fn.stdpath("state") .. "/undo"
vim.fn.mkdir(undo_dir, "p")
opt.undofile = true
opt.undodir = undo_dir .. "//"

local keymap = vim.keymap.set

keymap("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
keymap("n", "<leader>w", "<cmd>write<CR>", { desc = "Write buffer" })
keymap({ "n", "x" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
keymap("n", "<leader>Y", '"+Y', { desc = "Yank line to system clipboard" })
keymap({ "n", "x" }, "<leader>p", '"+p', { desc = "Paste from system clipboard" })

keymap("n", "<C-h>", "<C-w>h", { desc = "Focus left window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Focus lower window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Focus upper window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Focus right window" })

local function jump_diagnostic(count)
  return function()
    if vim.diagnostic.jump then
      vim.diagnostic.jump({ count = count, float = true })
    elseif count > 0 then
      vim.diagnostic.goto_next()
    else
      vim.diagnostic.goto_prev()
    end
  end
end

keymap("n", "[d", jump_diagnostic(-1), { desc = "Previous diagnostic" })
keymap("n", "]d", jump_diagnostic(1), { desc = "Next diagnostic" })
keymap("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic" })
keymap("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
keymap("n", "<leader>rc", function()
  vim.cmd("source " .. vim.fn.fnameescape(vim.env.MYVIMRC))
end, { desc = "Reload Neovim configuration" })

local text_group = vim.api.nvim_create_augroup("TextEditing", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = text_group,
  pattern = { "markdown", "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
})

-- Draw a usable screen before a first-run plugin download can block startup.
vim.cmd.colorscheme("habamax")

-- Bootstrap mini.nvim, then let mini.deps manage all optional plugins.
local package_root = vim.fn.stdpath("data") .. "/site"
local mini_path = package_root .. "/pack/deps/start/mini.nvim"
local mini_target = vim.fn.has("nvim-0.10") == 1 and "stable" or "v0.17.0"

local function notify_plugin_error(message)
  vim.schedule(function()
    vim.notify(message, vim.log.levels.WARN, { title = "Neovim plugins" })
  end)
end

local function bootstrap_mini()
  if vim.fn.isdirectory(mini_path) == 0 then
    if vim.fn.executable("git") ~= 1 then
      notify_plugin_error("Git is unavailable; starting without optional plugins.")
      return false
    end

    vim.api.nvim_echo({
      { "Installing mini.nvim for the first time; this may take a moment...", "WarningMsg" },
    }, false, {})
    vim.cmd("redraw")

    vim.fn.mkdir(vim.fn.fnamemodify(mini_path, ":h"), "p")
    local output = vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "--single-branch",
      "--branch",
      mini_target,
      "https://github.com/nvim-mini/mini.nvim",
      mini_path,
    })

    if vim.v.shell_error ~= 0 then
      vim.fn.delete(mini_path, "rf")
      notify_plugin_error("Failed to install mini.nvim; starting without optional plugins.\n" .. output)
      return false
    end
    vim.cmd("helptags ALL")
  end

  local loaded, load_error = pcall(vim.cmd, "packadd mini.nvim")
  if not loaded then
    notify_plugin_error("Failed to load mini.nvim; starting without optional plugins.\n" .. load_error)
  end
  return loaded
end

local deps_ok = false
if bootstrap_mini() then
  local require_ok, MiniDeps = pcall(require, "mini.deps")
  if require_ok then
    MiniDeps.setup({ path = { package = package_root } })

    local mini_spec = {
      source = "nvim-mini/mini.nvim",
      name = "mini.nvim",
      checkout = mini_target,
      monitor = mini_target == "stable" and "main" or "stable",
    }
    local mini_add_ok, mini_add_error = pcall(MiniDeps.add, mini_spec)
    if not mini_add_ok then
      notify_plugin_error("Failed to register mini.nvim with mini.deps.\n" .. mini_add_error)
    end

    local catppuccin_ok, catppuccin_error = pcall(MiniDeps.add, {
      source = "catppuccin/nvim",
      name = "catppuccin",
    })
    if not catppuccin_ok then
      notify_plugin_error("Failed to install Catppuccin; using the fallback theme.\n" .. catppuccin_error)
    end
    deps_ok = true
  else
    notify_plugin_error("Failed to load mini.deps; starting without optional plugins.\n" .. MiniDeps)
  end
end

local function setup_mini(module, config)
  if not deps_ok then
    return
  end
  local ok, plugin = pcall(require, module)
  if ok then
    plugin.setup(config or {})
  end
end

setup_mini("mini.ai")
setup_mini("mini.pairs")
setup_mini("mini.surround")
setup_mini("mini.comment")
setup_mini("mini.statusline", { use_icons = false })

local theme_ok, catppuccin = pcall(require, "catppuccin")
if theme_ok then
  catppuccin.setup({
    flavour = "mocha",
    term_colors = true,
    integrations = { mini = { enabled = true } },
  })
end

local colorscheme = theme_ok and "catppuccin-mocha" or "habamax"
if not pcall(vim.cmd.colorscheme, colorscheme) then
  vim.cmd.colorscheme("habamax")
end

local local_config = vim.fn.stdpath("config") .. "/init.local.lua"
if vim.fn.filereadable(local_config) == 1 then
  local ok, err = pcall(dofile, local_config)
  if not ok then
    vim.notify("Failed to load " .. local_config .. ":\n" .. err, vim.log.levels.ERROR)
  end
end
