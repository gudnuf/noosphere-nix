{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins; [
      # Color scheme - deep blue theme matching terminal
      tokyonight-nvim

      # File navigation
      telescope-nvim
      telescope-fzf-native-nvim
      plenary-nvim  # Required by telescope

      # File explorer
      neo-tree-nvim
      nvim-web-devicons  # Icons for neo-tree

      # Syntax highlighting
      nvim-treesitter.withAllGrammars

      # LSP support
      nvim-lspconfig

      # Autocomplete
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      luasnip
      cmp_luasnip

      # UI improvements
      which-key-nvim  # Shows keybindings
      lualine-nvim    # Status line
      bufferline-nvim # Buffer tabs

      # Git integration
      gitsigns-nvim

      # Quality of life
      comment-nvim    # Easy commenting
      nvim-autopairs  # Auto close brackets
    ];

    extraLuaConfig = ''
      -- Basic settings
      vim.opt.number = true              -- Line numbers
      vim.opt.relativenumber = true      -- Relative line numbers
      vim.opt.mouse = 'a'                -- Enable mouse
      vim.opt.ignorecase = true          -- Case insensitive search
      vim.opt.smartcase = true           -- Unless uppercase is used
      vim.opt.hlsearch = false           -- Don't highlight searches
      vim.opt.wrap = false               -- Don't wrap lines
      vim.opt.breakindent = true         -- Indent wrapped lines
      vim.opt.tabstop = 2                -- 2 spaces for tabs
      vim.opt.shiftwidth = 2             -- 2 spaces for indents
      vim.opt.expandtab = true           -- Use spaces instead of tabs
      vim.opt.termguicolors = true       -- True color support
      vim.opt.signcolumn = 'yes'         -- Always show sign column
      vim.opt.updatetime = 250           -- Faster completion
      vim.opt.timeoutlen = 300           -- Faster key sequence completion
      vim.opt.splitright = true          -- Vertical splits go right
      vim.opt.splitbelow = true          -- Horizontal splits go below
      vim.opt.scrolloff = 8              -- Keep 8 lines above/below cursor

      -- Leader key
      vim.g.mapleader = ' '
      vim.g.maplocalleader = ' '

      -- Tokyo Night theme (deep blue variant)
      require('tokyonight').setup({
        style = 'night',  -- Deep blue background
        transparent = true,  -- Use terminal background
        styles = {
          sidebars = 'transparent',
          floats = 'transparent',
        },
      })
      vim.cmd[[colorscheme tokyonight]]

      -- Telescope setup
      require('telescope').setup({
        defaults = {
          mappings = {
            i = {
              ['<C-u>'] = false,
              ['<C-d>'] = false,
            },
          },
        },
      })
      pcall(require('telescope').load_extension, 'fzf')

      -- Telescope keybindings
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live grep' })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find buffers' })
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Find help' })
      vim.keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = 'Recent files' })

      -- Neo-tree setup
      require('neo-tree').setup({
        close_if_last_window = true,
        window = {
          width = 30,
        },
        filesystem = {
          follow_current_file = {
            enabled = true,
          },
          use_libuv_file_watcher = true,
        },
      })
      vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>', { desc = 'Toggle file explorer', silent = true })

      -- Treesitter setup
      require('nvim-treesitter.configs').setup({
        highlight = {
          enable = true,
        },
        indent = {
          enable = true,
        },
      })

      -- LSP setup
      local lspconfig = require('lspconfig')

      -- Nix LSP
      lspconfig.nil_ls.setup({})

      -- Bash LSP (optional, if you want shell script support)
      -- lspconfig.bashls.setup({})

      -- LSP keybindings
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Show hover info' })
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code action' })
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename' })

      -- Autocomplete setup
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
          ['<Tab>'] = cmp.mapping.select_next_item(),
          ['<S-Tab>'] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        }, {
          { name = 'buffer' },
          { name = 'path' },
        })
      })

      -- Which-key setup
      require('which-key').setup({
        window = {
          border = 'single',
        },
      })

      -- Lualine setup (status line)
      require('lualine').setup({
        options = {
          theme = 'tokyonight',
        },
      })

      -- Bufferline setup (buffer tabs)
      require('bufferline').setup({
        options = {
          mode = 'buffers',
          separator_style = 'slant',
          show_buffer_close_icons = false,
          show_close_icon = false,
        },
      })

      -- Buffer navigation
      vim.keymap.set('n', '<Tab>', ':BufferLineCycleNext<CR>', { desc = 'Next buffer', silent = true })
      vim.keymap.set('n', '<S-Tab>', ':BufferLineCyclePrev<CR>', { desc = 'Previous buffer', silent = true })
      vim.keymap.set('n', '<leader>bd', ':bdelete<CR>', { desc = 'Delete buffer', silent = true })

      -- Gitsigns setup
      require('gitsigns').setup({
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
        },
      })

      -- Comment.nvim setup
      require('Comment').setup()

      -- Autopairs setup
      require('nvim-autopairs').setup()

      -- Quality of life keybindings
      vim.keymap.set('n', '<leader>w', ':w<CR>', { desc = 'Save file', silent = true })
      vim.keymap.set('n', '<leader>q', ':q<CR>', { desc = 'Quit', silent = true })
      vim.keymap.set('n', '<leader>x', ':x<CR>', { desc = 'Save and quit', silent = true })
      vim.keymap.set('n', '<Esc>', ':nohl<CR>', { desc = 'Clear search highlight', silent = true })

      -- Window navigation (works with tmux)
      vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
      vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to bottom window' })
      vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to top window' })
      vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })

      -- Split windows
      vim.keymap.set('n', '<leader>sv', ':vsplit<CR>', { desc = 'Split vertically' })
      vim.keymap.set('n', '<leader>sh', ':split<CR>', { desc = 'Split horizontally' })
    '';

    extraPackages = with pkgs; [
      # LSP servers
      nil  # Nix LSP (already in dev-tools but good to ensure)

      # Telescope dependencies
      ripgrep
      fd
    ];
  };
}
