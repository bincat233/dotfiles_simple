" This file is my universal .vimrc file.  It is used on all my systems.
" It contains all basic SETTINGS and MAPPINGS that not related to plugins.

" Don't try to be vi compatible
set nocompatible

" Turn on syntax highlighting
syntax on

" Turn on file type detection, load plugin and indent files
filetype plugin indent on

" Show line numbers
set number
"set relativenumber " Show relative line numbers (显示相对行号)

" Show file stats (line number, file size, etc) in the status bar
set ruler
" Encoding (how vim shall represent characters internally)
set encoding=utf-8

"" Word wraping (自动换行)
set nowrap " Don't wrap lines
"set wrap " Wrap long lines
"set textwidth=79 " Wrap at 79 characters
"set formatoptions=tcqrn1 " Auto-wrap comments

" Whitespace
set tabstop=2 " \t is 2 spaces (\t 宽度)
set softtabstop=2 " Tab is 2 spaces (tab 按键的宽度, 以及退格键删去的宽度. 和expandtab配合使用)
set shiftwidth=2 " Indent is 2 spaces (缩进宽度)
set expandtab " Use spaces instead of tabs (tab 按键插入空格, 退格键删去空格)
"set noexpandtab " Use tabs instead of spaces (tab 按键插入tab, 退格键删去tab)
set smarttab " Use `shiftwidth` for leading indentation, `(soft)tabstop` otherwise 
" NOTE: Use `:retab!` to convert tabs to spaces manually
"autocmd BufEnter *.py :setlocal ts=4 sts=4 sw=4 expandtab

" Cursor motion
set scrolloff=2 " Keep lines above and below cursor
set sidescrolloff=5 " Keep columns left and right of cursor
set backspace=indent,eol,start
set matchpairs+=<:> " use % to jump between pairs
set display+=lastline " Show last line when scrolling (显示不完整的最后一行)
"runtime! macros/matchit.vim

" Allow hidden buffers
set hidden " 切换buffer时隐藏旧buffer (必须)

" Status bar
set laststatus=2 " Always show status bar
set showmode " Show mode in status bar
"set noshowmode " 隐藏因为airline重复的 --INSERT--
set showcmd " Show command in status bar

" Searching
set magic " Use magic
set hlsearch " Highlight search results
set incsearch " Incremental search (search as you type)
"" Use <C-L> to clear the highlighting of :set hlsearch.
"if maparg('<C-L>', 'n') ==# ''
"  nnoremap <silent> <C-L> :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>
"endif
set ignorecase " Ignore case when searching
set smartcase " Ignore case unless search term contains capital letters
set showmatch " Show matching brackets


" Visualize tabs and newlines
"set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
"set listchars=tab:▸\ ,space:·,eol:¬,nbsp:␣
"set listchars=eol:¬,space:·,lead:\ ,trail:·,nbsp:◇,tab:→-,extends:▸,precedes:◂,multispace:···⬝,leadmultispace:\│\ \ \ ,	" Vim 9 support
set list " Show invisible characters

" Files and Directories
set undofile " 保留历史记录
set undodir=~/.undodir " 统一历史记录存放位置
set backupdir=/tmp "设置备份文件目录
set directory=/tmp "设置临时文件目录
set path=$PWD/** " 将当前工作路径设为Vim PATH

" Set abbreviations in insert mode
" @@<non-keyword-character> print my email.
iabbrev @@ isxiongzj@gmail.com

" Misc
set termguicolors " Enable 24-bit colors
set cursorline " Highlight current line
set cursorcolumn " Highlight current column
set mouse+=a " Enable mouse support
set mousemoveevent " Enable mouse move event
set wildmenu " Enable command-line completion (命令模式下的补全)
"set clipboard=unnamedplus " Copy/paste to system clipboard
set helplang=cn " 设置帮助文档语言
"set foldmethod=syntax "代码折叠
set complete-=i " Don't complete included file names
set nrformats-=octal " Don't use octal numbers when incrementing/decrementing with CTRL-A/CTRL-X
set autoread " Automatically reload files when changed outside of Vim
set whichwrap+=<,>,[,] " Move to next line with <Left>/<Right> at end of line
"set cmdheight=2 " More space for displaying messages
set completeopt=menu,menuone,noinsert " Better completion
set shortmess+=c " Don't pass messages to |ins-completion-menu|.
set showtabline=2 " Always show tabs
set signcolumn=yes " Always show signcolumn
"silent! set signcolumn=auto:9 " Show signcolumn only when needed
set timeoutlen=500 " Time to wait for a mapped sequence to complete (in milliseconds)
set splitbelow " Put new windows below current
set splitright " Put new windows right of current

" Toggle relative line numbers automatically
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
augroup END

" Turn on wrapping when editing text files
augroup Markdown
  autocmd!
  autocmd FileType markdown set wrap
	autocmd FileType text setlocal wrap
augroup END

"""""""""""""""""""" Some Basic Keybinding """"""""""""""""""""
" Set leader key to space (someone may use , or " )
" If having any conflict, checking with `:verbose map <leader>`
let mapleader = "\<Space>"

"" Searching with very magic (regex) by default
"nnoremap / /\v
"vnoremap / /\v
"cnoremap %s/ %smagic/
"cnoremap \>s/ \>smagic/
"nnoremap :g/ :g/\v
"nnoremap :g// :g//

" Move up/down editor lines
"nnoremap j gj
"nnoremap k gk

" Clear search highlight
map <leader><space> :let @/=''<cr> 

" Remap help key.
inoremap <F1> <Nop>
nnoremap <F1> <Nop>
vnoremap <F1> <Nop>
"
"" Formatting
"map <leader>q gqip

" Use leader key + l to toggle list mode on/off
"map <leader>l :set list!<CR>

" Use jk to escape insert mode
inoremap jk <esc>

" Copy/Paste to system clipboard
nmap <leader>y "+y
vmap <leader>y "+y
nmap <leader>d "+d
vmap <leader>d "+d
nmap <leader>p "+p
nmap <leader>P "+P
vmap <leader>p "+p
vmap <leader>P "+P

" Reload vimrc
nnoremap <leader>rc :source $MYVIMRC<cr> 

colorscheme catppuccin_frappe
