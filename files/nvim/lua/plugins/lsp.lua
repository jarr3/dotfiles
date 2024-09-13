-- LSP configurations
local utils = require("utils")
local formatters = {
  -- javascript = { "prettier" },
  -- javascriptreact = { "prettier" },
  typescript = { "prettier" },
  typescriptreact = { "prettier" },
  astro = { "prettier" },
  json = { "prettier" },
  jsonc = { "prettier" },
  -- html = { "prettier" },
  yaml = { "prettier" },
  css = { "stylelint", "prettier" },
  sh = { "shellcheck", "shfmt" },
  lua = { "stylua" },
  -- python = { "isort", "black" },
}
local servers = {
  "eslint",
  "tsserver",
  "lua_ls",
  "denols",
  "astro",
  "tailwindcss",
  "jsonls",
  "vimls",
  pylsp = {
    settings = {
      pylsp = {
        plugins = {
          pycodestyle = {
            ignore = {"E501"},
            maxLineLength = 79
          }
        }
      }
    }
  },
}

-- _G makes this function available to vimscript lua calls
_G.lsp_organize_imports = utils.lsp_organize_imports

local completion_setup = function()
  local cmp = require('cmp')

  cmp.setup({
    snippet = {
      expand = function(args)
        require('luasnip').lsp_expand(args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
      { name = 'path' },
    }, {
      { name = 'buffer' },
    })
  })
end

local lsp_on_attach = function(_, bufnr)
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(_)
      vim.cmd([[command! OR lua lsp_organize_imports()]])

      utils.nmap(bufnr, '<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
      utils.nmap(bufnr, '<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

      utils.nmap(bufnr, 'gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
      utils.nmap(bufnr, 'gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
      utils.nmap(bufnr, 'gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
      utils.nmap(bufnr, '<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
      utils.nmap(bufnr, '<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
      utils.nmap(bufnr, '<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
      utils.nmap(bufnr, 'gO', utils.lsp_organize_imports, 'Organize Imports')

      -- See `:help K` for why this keymap
      utils.nmap(bufnr, 'K', vim.lsp.buf.hover, 'Hover Documentation')
      utils.nmap(bufnr, '<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

      -- Lesser used LSP functionality
      utils.nmap(bufnr, 'gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
      utils.nmap(bufnr, '<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
      utils.nmap(bufnr, '<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
      utils.nmap(bufnr, '<leader>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end, '[W]orkspace [L]ist Folders')

      -- Create a command `:Format` local to the LSP buffer
      vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
        vim.lsp.buf.format()
      end, { desc = 'Format current buffer with LSP' })
    end,
  })
end

local lsp_setup = function()
  require('mason').setup()
  require('mason-lspconfig').setup()
  require('neodev').setup()

  -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = { "documentation", "detail", "additionalTextEdits", "documentHighlight" },
  }
  capabilities.textDocument.colorProvider = { dynamicRegistration = false }
  capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

  local mason_lspconfig = require('mason-lspconfig')
  mason_lspconfig.setup {
    ensure_installed = servers,
  }
  mason_lspconfig.setup_handlers {
    function(server_name)
      require('lspconfig')[server_name].setup {
        capabilities = capabilities,
        on_attach = lsp_on_attach,
        settings = servers[server_name],
        filetypes = (servers[server_name] or {}).filetypes,
      }
    end,
  }
end

return {
  {
    -- code completions, lsp, etc.
    'hrsh7th/nvim-cmp',
    dependencies = {
      {
	"L3MON4D3/LuaSnip",
	version = "v2.1",
	build = "make install_jsregexp"
      },
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
    },
    config = function()
      completion_setup()
    end
  },

  {
    "neovim/nvim-lspconfig",
    lazy = false,
    dependencies = {
      -- Helpers to install LSPs and maintain them
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      { 'j-hui/fidget.nvim', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
    config = function()
      lsp_setup()
    end
  },

  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      format_on_save = {
        timeout_ms = 2000,
        lsp_fallback = false,
      },
      formatters_by_ft = formatters,
    },
  },

  {
    "folke/trouble.nvim",
    config = true,
    keys = {
      { "<leader>xx", "<cmd>TroubleToggle<cr>" },
      { "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>" },
      { "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>" },
      { "<leader>xq", "<cmd>TroubleToggle quickfix<cr>" },
      { "<leader>xl", "<cmd>TroubleToggle loclist<cr>" },
    },
  },
  {
    'linux-cultist/venv-selector.nvim',
    dependencies = {
      'neovim/nvim-lspconfig',
      'nvim-telescope/telescope.nvim',
      'mfussenegger/nvim-dap-python'
    },
    opts = {
      -- Your options go here
      name = "venv",
      auto_refresh = false
    },
    event = 'VeryLazy',
    keys = {
      { '<leader>vs', '<cmd>VenvSelect<cr>' },
      { '<leader>vc', '<cmd>VenvSelectCached<cr>' },
    },
  },
}
