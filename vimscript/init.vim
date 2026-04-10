" -----------------------------------------
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  echo "Instalando vim-plug..."
  if executable('curl')
    silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  elseif executable('wget')
    silent execute '!wget -P '.data_dir.'/autoload/ --recursive --level=1 --no-directories --no-host-directories https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  else
    echoerr "Erro: curl ou wget não encontrados. Instale um deles para baixar o vim-plug."
  endif
  
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
" -----------------------------------------

let mapleader = " "
set autoindent
set clipboard+=unnamedplus
set ai ma si
set undofile
set number
set completeopt=longest,menuone
set nobackup
set nowritebackup
set encoding=utf-8
set fileencoding=utf-8
set foldmethod=expr         
set foldlevelstart=99

set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab

filetype plugin indent on

call plug#begin('~/.vim/plugged')

Plug 'neoclide/coc.nvim', {'branch': 'master', 'do': 'npm ci'}
Plug 'morhetz/gruvbox'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-fugitive'
Plug 'apzelos/blamer.nvim'
Plug 'sindrets/diffview.nvim'
Plug 'lewis6991/gitsigns.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'hrsh7th/nvim-cmp'
Plug 'akinsho/bufferline.nvim', { 'tag': '*' }
Plug 'nvim-lualine/lualine.nvim'
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'nvim-treesitter/nvim-treesitter'

call plug#end()

colorscheme gruvbox

nmap <leader>e :Vexplore<CR>

let g:NERDTreeIgnore = ['^node_modules$']

let g:fzf_layout = { "down": "~30%" } 

let g:coc_global_extensions = [
  \ 'coc-snippets', 
	\ 'coc-pairs', 
	\ 'coc-tsserver',
  \ 'coc-eslint', 
  \ 'coc-prettier', 
  \ 'coc-json',
	\	'coc-solargraph',
	\	'coc-rust-analyzer',
	\ ]
let g:mkdp_auto_start = 1

"commmand open vim config 
nmap <leader>cf :vsplit ~/.config/nvim/init.vim<cr>
nmap <leader>cr :CocRestart<cr>

" GoTo code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

function! LightlineFilename()
  return expand('%:.')
endfunction

" Highlight the symbol and its references when holding the cursor
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

" Remap find files
nmap <leader>ff :Files <CR>
nmap <leader>fg :Rg<cr>
nmap <C-s> :w!<CR>
nmap <C-q> :bd<CR>
nmap <S-h> :bprev<CR>
nmap <S-l> :bnext<CR>
nmap <leader>gs :GFiles?<CR>
nmap <leader>gb :lua require('gitsigns').toggle_current_line_blame()<CR>

nnoremap <C-j> :m .+1<CR>==
vnoremap <C-j> :m '>+1<CR>gv=gv

nnoremap <C-k> :m .-2<CR>==
vnoremap <C-k> :m '<-2<CR>gv=gv

nmap <leader>ca  <Plug>(coc-codeaction)
" Fix autofix problem of current line
nmap <leader>qf  <Plug>(coc-fix-current)
" Use K to show documentation in preview window

nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction


inoremap <expr> <TAB> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
" --------------------------------------------------------

inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

lua << EOF
require('lualine').setup {
  options = {
    icons_enabled = true,
			theme = 'gruvbox',
    always_divide_middle = true,
    always_show_tabline = true,
  },
  sections = {
    lualine_c = {
      {
        'filename',
        path = 4,  
        shorting_target = 40,  
				symbols = {
						modified = " ●",
						alternate_file = "#",
						directory = "",
      	},
      }
    },
		lualine_b = {
				{
						"branch",
						fmt = function(branch)
								local limit = 20
								return branch:sub(1, limit) .. (branch:len() > limit and "…" or "")
						end,
				},
				"diff",
				"diagnostics",
		},
  }
}
require("bufferline").setup {
  options = {
    mode = "buffers",
    numbers = "ordinal",
    close_command = "bdelete! %d",
    right_mouse_command = "bdelete! %d",
    left_mouse_command = "buffer %d",
    middle_mouse_command = nil,

    indicator = {
      icon = '▎',
      style = 'icon',
    },

    buffer_close_icon = '',
    modified_icon = '●',
    close_icon = '',
    left_trunc_marker = '',
    right_trunc_marker = '',

    max_name_length = 18,
    max_prefix_length = 15,
    tab_size = 18,

    diagnostics = "nvim_lsp",
    diagnostics_update_in_insert = false,
    custom_filter = function(buf_number)
      local filetype = vim.bo[buf_number].filetype
      if filetype == "NvimTree" then
        return false
      end
      return true
    end,
    offsets = {
      {
        filetype = "NvimTree", 
        text = "File Explorer",
        text_align = "center",
        separator = true,
      }
    },

    show_buffer_icons = true,
    show_buffer_close_icons = true,
    show_close_icon = true,
    show_tab_indicators = true,
    persist_buffer_sort = true,

    separator_style = "slant",
    enforce_regular_tabs = false,
    always_show_bufferline = true,
  }
}
require("ibl").setup()
require('gitsigns').setup {
  signs = {
    add          = { text = '┃' },
    change       = { text = '┃' },
    delete       = { text = '|' },
    topdelete    = { text = '|' },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
  },
  signs_staged = {
    add          = { text = '┃' },
    change       = { text = '┃' },
    delete       = { text = '|' },
    topdelete    = { text = '|' },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
  },
  signs_staged_enable = true,
  signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
  numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
  linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
  watch_gitdir = {
    follow_files = true
  },
  auto_attach = true,
  attach_to_untracked = false,
  current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
    delay = 1000,
    ignore_whitespace = false,
    virt_text_priority = 100,
    use_focus = true,
  },
  current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
  sign_priority = 6,
  update_debounce = 100,
  status_formatter = nil, -- Use default
  max_file_length = 40000, -- Disable if file is longer than this (in lines)
  preview_config = {
    -- Options passed to nvim_open_win
    border = 'single',
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1
  },
}
EOF
highlight GitSignsCurrentLineBlame guifg=#909090 gui=italic
