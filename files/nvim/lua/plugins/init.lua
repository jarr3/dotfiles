return {
  -- Improve vim skills by playing games
  {
    "ThePrimeagen/vim-be-good",
  },

  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
  },

  {
    "lervag/vimtex",
    ft = { "tex" },
    lazy = false, -- we don't want to lazy load VimTeX
    init = function()
      -- Use latexmk for compilation and set the output directory to "build"
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_compiler_latexmk = {
        build_dir = "build", -- output directory
        aux_dir = "build", -- auxiliary files directory
        options = {
          "-pdf", -- compile to PDF
          -- "-interaction=nonstopmode", -- nonstop interaction mode
          "-synctex=1", -- enable synctex for better forward/backward search
          "-shell-escape", -- allow shell escapes if needed
          "-bibtex",
          "-output-format=pdf",
          "-noemulate-aux-dir",
        },
      }
      vim.g.vimtex_view_method = "zathura"

      -- vim.g.vimtex_view_general_viewer = "zathura"
      -- vim.g.vimtex_view_general_options = "--unique file:@pdf\\#src:@line@tex"
    end,
  },

  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- Full signature help, docs and completion
  {
    "folke/neodev.nvim",
    event = {
      "BufReadPre",
      "BufNewFile",
    },
    opts = {},
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require "configs.lspconfig"
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
      dependencies = {
        "williamboman/mason.nvim",
        "neovim/nvim-lspconfig",
      },
      config = function()
        local servers = {
          "html", -- HTML LSP
          "rust_analyzer", -- Rust Analyzer
          "pyright",
          "tailwindcss", -- Tailwind CSS LSP
          "sqls", -- SQL LSP
          "clangd", -- C/C++ LSP
          "eslint", -- ESLint LSP
          "nextls", -- Next.js LSP
          "jsonls", -- JSON LSP
          "bashls", -- Bash LSP
          "cssls", -- CSS LSP
          "dockerls", -- Dockerfile LSP
          "docker_compose_language_service", -- Docker Compose LSP
          "yamlls", -- YAML LSP
          "nginx_language_server", -- Nginx LSP
          "lua_ls", -- Lua LSP
          "gopls", -- golang
          "emmet_ls",
          "cmake",
        }
      
        local lspconfig = require "lspconfig"
        local masonlsp = require "mason-lspconfig"
        local nvlsp = require "nvchad.configs.lspconfig"

        masonlsp.setup({
          ensure_installed = servers,
          handlers = {
            function(server_name)
              lspconfig[server_name].setup {
                on_attach = nvlsp.on_attach,
                on_init = nvlsp.on_init,
                capabilities = nvlsp.capabilities,
              }
            end,
          },
        })
      end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "cpp",
        "python",
        "json",
      },
    },
  },

  {
    "jose-elias-alvarez/null-ls.nvim",
    config = function()
      require "../custom/null-ls.lua"
    end,
  },

  {
    -- snippet plugin
    "L3MON4D3/LuaSnip",
    dependencies = "rafamadriz/friendly-snippets",
    opts = { history = true, updateevents = "TextChanged,TextChangedI" },
    config = function(_, opts)
      require("custom.luasnip").luasnip(opts)
    end,
  },

  -- Single tabpage interface for easily cycling through diffs
  { "tpope/vim-fugitive" },

  { "rbong/vim-flog", dependencies = {
    "tpope/vim-fugitive",
  }, lazy = false },

  { "sindrets/diffview.nvim", lazy = false },

  {
    "kevinhwang91/nvim-bqf",
    lazy = false,
  },
}
