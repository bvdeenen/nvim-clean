vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Bart
vim.g.loaded_matchparen = false
vim.cmd([[ colorscheme gruvbox ]])
vim.o.tildeop = true
vim.opt.expandtab = true
vim.g.have_nerd_font = true

-- [[ Setting options ]]
vim.o.number = true
vim.o.mouse = "a"
vim.o.showmode = false

-- Sync clipboard between OS and Neovim.
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

vim.o.breakindent = true
vim.opt.autoindent = false
vim.opt.cindent = false
vim.opt.smartindent = false
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.o.undofile = true
vim.o.ignorecase = false
vim.o.smartcase = false
vim.o.signcolumn = "yes"
vim.o.updatetime = 250
vim.o.timeoutlen = 700
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.o.inccommand = "split"
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true

-- [[ Basic Keymaps ]]
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- [[ Basic Autocommands ]]
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- [[ Plugins ]]
-- vim.pack.add() clones the plugin on first run and registers it in the packpath.
-- After all declarations, packloadall makes them available for require().

local gh = function(x)
	return "https://github.com/" .. x
end

vim.pack.add({
	-- Dependencies
	gh("nvim-lua/plenary.nvim"),
	gh("nvim-tree/nvim-web-devicons"),
	gh("MunifTanjim/nui.nvim"),
	gh("L3MON4D3/LuaSnip"),
	-- nvim-cmp sources
	gh("hrsh7th/cmp-nvim-lsp"),
	gh("hrsh7th/cmp-buffer"),
	gh("hrsh7th/cmp-path"),
	gh("saadparwaiz1/cmp_luasnip"),
	-- Plugins
	gh("kylechui/nvim-surround"),
	gh("tpope/vim-fugitive"),
	gh("stevearc/aerial.nvim"),
	gh("nvim-neo-tree/neo-tree.nvim"),
	gh("windwp/nvim-autopairs"),
	gh("mason-org/mason.nvim"),
	gh("mason-org/mason-lspconfig.nvim"),
	gh("nvim-treesitter/nvim-treesitter"),
	gh("nvim-telescope/telescope.nvim"),
	gh("hrsh7th/nvim-cmp"),
	gh("stevearc/conform.nvim"),
})

-- Ensure all start/ plugins are sourced before require() calls below.
vim.cmd("packloadall")

-- [[ Plugin configuration ]]

require("nvim-surround").setup({})

-- Tmux-aware window navigation: move between vim splits; at edge, navigate tmux panes.
local function tmux_navigate(direction)
	local nr = vim.fn.winnr()
	vim.cmd("wincmd " .. direction)
	if vim.fn.winnr() == nr and vim.env.TMUX then
		local tmux_dir = ({ h = "L", j = "D", k = "U", l = "R" })[direction]
		vim.fn.system("tmux select-pane -t " .. vim.env.TMUX_PANE .. " -" .. tmux_dir)
	end
end

vim.keymap.set("n", "<c-h>", function()
	tmux_navigate("h")
end)
vim.keymap.set("n", "<c-j>", function()
	tmux_navigate("j")
end)
vim.keymap.set("n", "<c-k>", function()
	tmux_navigate("k")
end)
vim.keymap.set("n", "<c-l>", function()
	tmux_navigate("l")
end)

require("aerial").setup({})

require("neo-tree").setup({
	filesystem = {
		window = {
			mappings = {
				["\\"] = "close_window",
			},
		},
	},
})
vim.keymap.set("n", "\\", ":Neotree reveal<CR>", { desc = "NeoTree reveal", silent = true })

require("nvim-autopairs").setup({})

require("mason").setup({})
require("mason-lspconfig").setup({})

require("nvim-treesitter").setup({})

local cmp = require("cmp")
local luasnip = require("luasnip")
cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-Space>"] = cmp.mapping.complete(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
		["<Tab>"] = cmp.mapping.select_next_item(),
		["<S-Tab>"] = cmp.mapping.select_prev_item(),
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "path" },
		{ name = "buffer" },
	}),
})

require("conform").setup({
	formatters_by_ft = {
		python = { "black" },
		javascript = { "prettier" },
		typescript = { "prettier" },
		typescriptreact = { "prettier" },
		json = { "prettier" },
		yaml = { "prettier" },
		bash = { "shfmt" },
		lua = { "stylua" },
	},
	format_on_save = { timeout_ms = 2000, lsp_fallback = true },
})

-- [[ LSP ]]
vim.lsp.config("gopls", {
	cmd = { "gopls" },
	filetypes = { "go", "gomod", "gowork", "gotmpl" },
	root_markers = { "go.mod", "go.work", ".git" },
	settings = {
		gopls = {
			hints = {
				assignVariableTypes = true,
				compositeLiteralFields = true,
				compositeLiteralTypes = true,
				constantValues = true,
				functionTypeParameters = true,
				parameterNames = true,
				rangeVariableTypes = true,
			},
		},
	},
})

vim.lsp.enable("gopls")
vim.lsp.enable("pyright")
vim.lsp.enable("bashls")
vim.lsp.enable("stylua")

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "rs", "gopls", "lua" },
	callback = function()
		vim.treesitter.start()
	end,
})

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
	end,
})

vim.keymap.set("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>")

-- [[ Telescope keymaps ]]
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
vim.keymap.set("n", "<leader>fC", builtin.commands, { desc = "Telescope commands" })
vim.keymap.set("n", "<leader>fm", builtin.keymaps, { desc = "Telescope keymaps" })

vim.keymap.set("n", "<leader>h", function()
	local current = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
	vim.lsp.inlay_hint.enable(not current, { bufnr = 0 })
end, { desc = "Toggle inlay hints" })
