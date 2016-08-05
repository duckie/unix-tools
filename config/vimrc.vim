set nocompatible
filetype off
" Cleanup autocommands to avoid multiple sourcing 
autocmd!

" Initilialize Vundle
set rtp+=~/.tools/external/vim/vundle
call vundle#begin()
Plugin 'tpope/vim-surround'
Plugin 'Valloric/YouCompleteMe'
Plugin 'christoomey/vim-tmux-navigator'
call vundle#end()

filetype plugin indent on
filetype on
filetype plugin on
syn on
" Cope with horribly slow yaml syntax of vim 7.4
au BufNewFile,BufRead *.yaml,*.yml so ~/.vim/yaml.vim

" Disable vim backup
set nobackup
set noswapfile

" General layout
set background=dark " Set contrasts to make a dark bh usable
set noerrorbells " Get rid of this shit
set novisualbell " Get rid of this shit
set hidden " Hides abandoned buffers
set ttyfast

" Colors and encoding
colorscheme molokai
set t_Co=256 " Trick for rich color set to worl
set encoding=utf-8
set fileencoding=utf-8

" Status bar
set ruler " Displays cursir position
set laststatus=2

" Search config
set showmatch
set incsearch

" Line numbers
set number
set ignorecase

" Indentation
filetype indent on
set autoindent
set smartindent
set cindent
set nowrap

" Tabulation management
set backspace=indent,eol,start
set tabstop=2
set shiftwidth=2
set softtabstop=2
" set shortmess=filnxtToO 
set smarttab
set expandtab

" Folding management
set foldenable
set foldopen-=search
set foldopen-=undo
"  Trick to avoid slow downs due to the folding into syntax mode
"  Those 3 lines were found in the Vim wiki
"  http://vim.wikia.com/wiki/Keep_folds_closed_while_inserting_text
set foldmethod=manual
let w:last_fdm=&foldmethod
autocmd InsertEnter * let w:last_fdm=&foldmethod | setlocal foldmethod=manual
autocmd InsertLeave * let &l:foldmethod=w:last_fdm
"  Those are mine
autocmd BufReadPost * set foldmethod=syntax | set foldlevel=0 | set foldmethod=manual
command Refold set foldmethod=syntax | set foldlevel=0 | set foldmethod=manual


" Bash like file completion in command line
set wildmenu
set wildmode=list:longest

" Show the line where the cursor lies
set cursorline
command Cl execute ":set cursorcolumn"
command NoCl execute ":set nocursorcolumn"
command Nocl execute ":set nocursorcolumn"

" Recentering the text
nmap n nzz
nmap N Nzz
imap ² <Esc>

" Function to get variables first in buffer then in global
" by Salman Halim
" http://vim.wikia.com/wiki/Letting_variable_values_be_overwritten_in_a_script
" 
function! GetVar(...)
  let varName=a:1
  if (exists("a:2"))
    let retVal=a:2
  else
    let retVal=-1
  endif
  if (exists ("b:" . varName))
    exe "let retVal=b:" . varName
  elseif (exists ("g:" . varName))
    exe "let retVal=g:" . varName
  endif
  return retVal
endfunction

" Comment/Uncomment
autocmd FileType c,cpp            let b:comment_leader = '//'
autocmd FileType java,scala       let b:comment_leader = '//'
autocmd FileType javascript,json  let b:comment_leader = '//'
autocmd FileType php              let b:comment_leader = '//'
autocmd FileType sh,ruby,python   let b:comment_leader = '#'
autocmd FileType conf,fstab       let b:comment_leader = '#'
autocmd FileType tex              let b:comment_leader = '%'
autocmd FileType mail             let b:comment_leader = '> '
autocmd FileType vim              let b:comment_leader = '" '
autocmd FileType lua              let b:comment_leader = '-- '

noremap <silent> ,c :s/^\(\s*\)/\=submatch(1).GetVar("comment_leader","#")/g <bar> :nohl<cr>
noremap <silent> ,x :s,^\(\s*\)<c-r>=GetVar("comment_leader","#")<cr>,\1,g <bar> :nohl <cr>

" Avoid vimdiff to diff on spaces
set diffopt+=iwhite

" Automatically expand %% into the current file directory
cabbr <expr> %% expand('%:p:h')

" C++ macros
let @i='?}^M%^^t(byT t{l%/\w^Mt ll"0Pt;lxA {^M}^M^['
set fillchars=vert:\ ,stl:\ ,stlnc:\
"  Switch between header and implementation
function SwitchHeaderImpl()
  let ext=expand("%:e")
  if ext ==? "c" || ext ==? "cc" || ext == "cpp"
    return expand("%:r").".h*"
  elseif ext ==? "h" || ext ==? "hh" || ext == "hpp"
    return expand("%:r").".c*"
  endif
endfunction
"  Mapping on shortcuts
map ,h :exec 'e '.SwitchHeaderImpl()<CR>
map ,H :exec 'tab drop '.SwitchHeaderImpl()<CR>

" Custom tab pages with numbers
set showtabline=2

function MyTabLabel(n)
  let buflist = tabpagebuflist(a:n)
  let winnr = tabpagewinnr(a:n)
  let name = bufname(buflist[winnr - 1])
  if name == ""
    return ' {'.a:n.'} '
  else
    return ' {'.a:n.'} '. split(bufname(buflist[winnr - 1]),"/")[-1]
  endif
endfunction

function MyTabLine()
  let s = ''
  for i in range(tabpagenr('$'))
    " select the highlighting
    if i + 1 == tabpagenr()
      let s .= '%#TabLineSel#'
    else
      let s .= '%#TabLine#'
    endif
    " the label is made by MyTabLabel()
    let s .= '%{MyTabLabel(' . (i + 1) . ')} '
  endfor

  " after the last tab fill with TabLineFill and reset tab page nr
  let s .= '%#TabLineFill#%T'

  return s
endfunction

set tabline=%!MyTabLine()

" Plugins config
let g:ycm_min_num_of_chars_for_completion=3
let g:ycm_confirm_extra_conf=0
let g:ycm_goto_buffer_command = 'new-tab'
set completeopt=menuone

" Shortcuts to plugins
noremap <C-H> :YcmCompleter GoTo<cr>
map <C-I> :pyf /usr/share/clang/clang-format.py<cr>
