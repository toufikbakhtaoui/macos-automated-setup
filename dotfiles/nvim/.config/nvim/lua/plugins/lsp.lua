return {
  {
    'neovim/nvim-lspconfig',
    event = 'BufReadPre',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      -- Configuration moderne des diagnostics (API 0.11+)
      vim.diagnostic.config({
        virtual_text = {
          prefix = "●",
          spacing = 2,
        },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN]  = "",
            [vim.diagnostic.severity.HINT]  = "",
            [vim.diagnostic.severity.INFO]  = "",
          },
        },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

      -- Configuration LSP
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          local bufnr = args.buf

          -- Mappings de base
          local opts = { buffer = bufnr }
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
          vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
          vim.keymap.set('n', '<leader>f', function()
            vim.lsp.buf.format({ async = true })
          end, opts)

          -- Gestion stable des inlay hints
          if client.supports_method('textDocument/inlayHint') then
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          end
        end,
      })

      -- Configuration Mason
      require('mason').setup({
        ui = {
          border = "rounded",
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
          }
        }
      })

      require('mason-lspconfig').setup({
        ensure_installed = {
          'lua_ls',
          'sqls',
          'ansiblels',
          'dockerls',
          'yamlls'
        },
        automatic_installation = true,
      })

      -- Configuration des serveurs LSP
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      local lspconfig = require('lspconfig')

      -- Lua
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = { version = 'LuaJIT' },
            diagnostics = { globals = { 'vim' } },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false
            },
            telemetry = { enable = false },
          }
        }
      })

      -- SQL
      lspconfig.sqls.setup({
        capabilities = capabilities,
        on_attach = function(client)
          client.server_capabilities.documentFormattingProvider = false
        end
      })

      -- Ansible
      lspconfig.ansiblels.setup({
        capabilities = capabilities,
        settings = {
          ansible = {
            ansible = {
              path = "ansible"
            },
            ansibleLint = {
              enabled = true,
              path = "ansible-lint"
            },
            executionEnvironment = {
              enabled = false
            }
          }
        }
      })

      -- Docker
      lspconfig.dockerls.setup({
        capabilities = capabilities
      })

      -- YAML
      lspconfig.yamlls.setup({
        capabilities = capabilities,
        settings = {
          yaml = {
            schemas = {
              kubernetes = "/*.yaml",
              ["http://json.schemastore.org/github-workflow"] = ".github/workflows/*",
              ["http://json.schemastore.org/github-action"] = ".github/action.yml",
              ["http://json.schemastore.org/ansible-stable-2.9"] = "roles/tasks/*.yml",
              ["http://json.schemastore.org/prettierrc"] = ".prettierrc.yml",
              ["http://json.schemastore.org/kustomization"] = "kustomization.yaml",
              ["http://json.schemastore.org/ansible-playbook"] = "*play*.yml",
              ["http://json.schemastore.org/chart"] = "Chart.yaml"
            },
            format = { enable = true },
            validate = true,
            completion = true,
            hover = true
          }
        }
      })
    end
  },
  {
    'williamboman/mason.nvim',
    cmd = 'Mason',
    build = ':MasonUpdate',
  },
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
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
        }, {
          { name = 'buffer' },
          { name = 'path' },
        })
      })
    end
  }
}

