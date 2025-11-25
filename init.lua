-- General settings
vim.o.clipboard = "unnamedplus"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.ttyfast = true



-- Keymaps
vim.keymap.set('n', '<leader>o', ':update<CR> :source<CR>')
vim.keymap.set('n', '<leader>w', ':write<CR>')
vim.keymap.set('n', '<leader>q', ':quit<CR>')

vim.keymap.set({ 'n', 'v', 'x' }, '<leader>y', '"+y<CR>')
vim.keymap.set({ 'n', 'v', 'x' }, '<leader>d', '"+d<CR>')

-- Plugins
vim.pack.add({
	{ src = "https://github.com/vague2k/vague.nvim" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter-context" },
	{ src = "https://github.com/HiPhish/rainbow-delimiters.nvim" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/chomosuke/typst-preview.nvim" },
	{ src = "https://github.com/simrat39/rust-tools.nvim" },
	{ src = "https://github.com/hrsh7th/nvim-cmp" },
	{ src = "https://github.com/hrsh7th/cmp-nvim-lsp" },
	{ src = "https://github.com/hrsh7th/cmp-buffer" },
	{ src = "https://github.com/hrsh7th/cmp-path" },
	{ src = "https://github.com/windwp/nvim-autopairs" },
	{ src = "https://github.com/L3MON4D3/LuaSnip", depends = { "saadparwaiz1/cmp_luasnip" } },
	{ src = "https://github.com/saadparwaiz1/cmp_luasnip" },
	{ src = "https://github.com/rebelot/kanagawa.nvim" },
	{ src = "/home/koushikk/Documents/lua/toodles.nvim" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim", depends = { "nvim-lua/plenary.nvim" } },
	{ src = "https://github.com/windwp/nvim-ts-autotag" },
	{ src = "https://github.com/JoosepAlviste/nvim-ts-context-commentstring" },
	{ src = "https://github.com/numToStr/Comment.nvim" },
})

vim.opt.rtp:append(vim.fn.expand("~/Documents/lua/toodles.nvim"))
vim.opt.rtp:append(vim.fn.expand("~/Documents/lua/shik.nvim"))
require("toodle").setup()
require("shik").setup()

-- Diagnostics
vim.diagnostic.config({
	virtual_text = { prefix = "●", spacing = 4 },
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
})

local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

require("nvim-autopairs").setup({
	check_ts = true,
	enable_check_bracket_line = false,
	fast_wrap = {},
})

local cmp_autopairs = require("nvim-autopairs.completion.cmp")
local cmp = require("cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

local luasnip = require("luasnip")
cmp.setup({
	snippet = {
		expand = function(args) luasnip.lsp_expand(args.body) end,
	},
	mapping = {
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				vim.api.nvim_feedkeys(
					vim.api.nvim_replace_termcodes("    ", true, false, true),
					"n",
					true
				)
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
		["<CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
		["<C-Space>"] = cmp.mapping.complete(),
	},
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
	}, {
		{ name = "buffer" },
		{ name = "path" },
	}),
})

cmp.setup.cmdline({ '/', '?' }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = { { name = 'buffer' } }
})

cmp.setup.cmdline(':', {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({ { name = 'path' } }, { { name = 'cmdline' } })
})

vim.api.nvim_create_autocmd('LspAttach', {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		local opts = { buffer = ev.buf }
		vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
		vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
		vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
		vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
		vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
		vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
		vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
		vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
		vim.keymap.set('n', '<leader>de', vim.diagnostic.open_float, opts)
		
		vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)
	end,
})

vim.cmd("set completeopt+=menu,menuone,noselect")

-- Skip deprecated module
vim.g.skip_ts_context_commentstring_module = true

require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"svelte", "javascript", "typescript", "tsx", "rust", "lua",
		"python", "html", "css", "json", "jsdoc", "markdown","zig","c","cpp",
	},
	highlight = { enable = true, additional_vim_regex_highlighting = true },
	indent = { enable = true },
})

require('nvim-ts-autotag').setup()

require('ts_context_commentstring').setup({
	enable_autocmd = false,
})

require('Comment').setup({
	pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
})

require("rainbow-delimiters.setup").setup({})

require("treesitter-context").setup({
	enable = true,
	max_lines = 3,
	trim_scope = 'outer',
})

require("telescope").setup({
	defaults = {
		prompt_prefix = "🔍 ",
		selection_caret = " ",
		sorting_strategy = "ascending",
		layout_config = { prompt_position = "top" },
	},
})
local builtin = require("telescope.builtin")
vim.keymap.set('n', '<leader>f', builtin.find_files)
vim.keymap.set('n', '<leader>g', builtin.live_grep)
vim.keymap.set('n', '<leader>h', builtin.help_tags)

require("oil").setup()
vim.keymap.set('n', '<leader>e', ":Oil<CR>")
vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)

local lspconfig = require('lspconfig')

lspconfig.ts_ls.setup({
	on_attach = function(client, bufnr)
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
		
		local opts = { buffer = bufnr }
		vim.keymap.set('n', '<leader>to', function()
		end, opts)
		
		vim.keymap.set('n', '<leader>tu', function()
		end, opts)
	end,
	settings = {
		typescript = {
			inlayHints = { enable = false },
			suggest = { completeFunctionCalls = true },
		},
		javascript = {
			inlayHints = { enable = false },
			suggest = { completeFunctionCalls = true },
		},
	},
})

lspconfig.eslint.setup({
	on_attach = function(client, bufnr)
		vim.api.nvim_create_autocmd("BufWritePre", {
			buffer = bufnr,
			command = "EslintFixAll",
		})
	end,
})

lspconfig.emmet_ls.setup({
	cmd = { 'emmet-language-server', '--stdio' },
	filetypes = { 'html', 'css', 'scss', 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'svelte' },
})

lspconfig.biome.setup({})
lspconfig.tinymist.setup({})


lspconfig.zls.setup({
	cmd = { "zls" },
	on_attach = function(client, bufnr)
		local opts = { buffer = bufnr }

		-- Keymaps for Zig-specific LSP actions
		vim.keymap.set('n', '<leader>zb', ':!zig build run<CR>', opts)
		vim.keymap.set('n', '<leader>zr', function()
			vim.cmd('write')
			vim.cmd('!zig run %')
		end, opts)

		vim.keymap.set('n', '<leader>zf', function()
			vim.lsp.buf.format({ async = true })
		end, opts)
	end,
	settings = {},
})

require('lspconfig').zls.setup({
  cmd = { "zls" },
  settings = {
    zls = {
      enable_autofix = true,
      warn_style = true,
      include_at_in_builtins = true,
    },
  },
})


vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.zig",
	callback = function()
		vim.lsp.buf.format({ async = false })
	end,
})


require('rust-tools').setup({
	tools = {
		autoSetHints = false,
		inlay_hints = {
            auto = false,
			show_parameter_hints = false,
		},
	},
	server = {
		on_attach = function(client, bufnr)
			if client.name == "rust_analyzer" then
				vim.api.nvim_create_autocmd("BufWritePre", {
					buffer = bufnr,
					callback = function()
						vim.lsp.buf.format({ async = false })
					end,
				})
			end
			local opts = { buffer = bufnr }
			vim.keymap.set('n', '<leader>rr', ':RustRunnables<CR>', opts)
			vim.keymap.set('n', '<leader>rd', ':RustDebuggables<CR>', opts)
			vim.keymap.set('n', '<leader>rt', ':RustTestNearest<CR>', opts)
			vim.keymap.set('n', '<leader>rT', ':RustTest<CR>', opts)
			vim.keymap.set('n', '<leader>rc', ':RustOpenCargo<CR>', opts)
			vim.keymap.set('n', '<leader>ha', ':RustHoverActions<CR>', opts)
		end,
		settings = {
			["rust-analyzer"] = {
				cargo = { allFeatures = true },
				checkOnSave = { enable = true },
				inlayHints = { 
                    enable = false,
                    chainingHints = { enable = false },
                    typeHints = { enable = false },
                    parameterHints = { enable = false }, 
                },
			},
		},
	},
})

-- lspconfig.lua_ls.setup({
-- 	settings = {
-- 		Lua = {
-- 			runtime = { version = "LuaJIT" },
-- 			diagnostics = {
-- 				globals = { "vim","love" },
-- 				unusedLocalExclude = { "_*" },
-- 				disable = { "lowercase-global", "trailing-space" },
-- 			},
-- 			workspace = {
--                 
-- 				library = vim.list_extend(
--                     vim.api.nvim_get_runtime_file("", true),
--                 {
--                     vim.fn.expand("~/.local/share/love-api"),
--                 }
--                 ),
-- 				checkThirdParty = false,
-- 			},
-- 			telemetry = { enable = false },
-- 		},
-- 	},
-- })
-- Helper: pick the best available LÖVE API stub path
local love_api_path = vim.fn.expand("~/.local/share/love-api")
local builtin_love_stubs =
  vim.fn.stdpath("data") .. "/mason/packages/lua-language-server/meta/3rd/love2d/library"
local love_final_path = love_api_path

-- Prefer built‑in stubs if they exist
if vim.fn.isdirectory(builtin_love_stubs) == 1 then
  love_final_path = builtin_love_stubs
elseif vim.fn.isdirectory("/usr/share/lua-language-server/meta/3rd/love2d/library") == 1 then
  -- fallback for system‑wide LuaLS installations
  love_final_path = "/usr/share/lua-language-server/meta/3rd/love2d/library"
end

-- Configure LuaLS
require("lspconfig").lua_ls.setup({
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = {
        globals = { "vim", "love" },
        unusedLocalExclude = { "_*" },
        disable = { "lowercase-global", "trailing-space" },
      },
      workspace = {
                userThirdParty = {os.getenv("HOME") .. ".local/share/LuaAddons"},
                checkThirdParty = "Apply"
            },
      telemetry = { enable = false },
    },
  },
})



-- C 
lspconfig.clangd.setup({
    -- Command to execute (should match the executable name installed via pacman)
    cmd = { "clangd" },

    -- Filetypes this server should be active for
    filetypes = { "c", "cpp", "objc", "objcpp" },

    -- Recommended setup for clangd-specific options:
    -- This sets initialization options for clangd
    init_options = {
        -- Always suggest the use of the compile_commands.json file
        --fallbackFlags = { "-std=c17", "-Wall" },
    },
})

require("toodle")
require("shik")

 vim.o.termguicolors = true
-- -- vim.cmd("colorscheme kanagawa")
vim.cmd [[ colorscheme murphy ]]
--
--



