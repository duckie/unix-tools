set nocompatible
filetype off
" Cleanup autocommands to avoid multiple sourcing 
autocmd!

" Initilialize Vundle
"if has('nvim')
"set rtp+=~/.tools/external/vim/vim-plug
"call plug#begin('~/.vim/plugged')
"Plug 'tpope/vim-surround'
"Plug 'ycm-core/YouCompleteMe'
"call plug#end()
"endif

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
autocmd FileType terraform,hcl    let b:comment_leader = '//'
autocmd FileType sh,ruby,python   let b:comment_leader = '#'
autocmd FileType conf,fstab       let b:comment_leader = '#'
autocmd FileType tex              let b:comment_leader = '%'
autocmd FileType mail             let b:comment_leader = '> '
autocmd FileType vim              let b:comment_leader = '" '
autocmd FileType lua              let b:comment_leader = '-- '
autocmd FileType go               call s:setup_go()
function! s:setup_go()
  let b:comment_leader = '//'
  set tabstop=4
  set shiftwidth=4
  set softtabstop=4
  set smarttab
  set expandtab!
endfunction

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
function SwitchHeaderImpl(open_command)
python << endpython
import vim, os

# Static data
h_ext = [".h",".hh",".hpp",".hxx"]
c_ext = [".c",".cc",".cpp",".cxx"]

# Extract current file data
filepath = vim.current.buffer.name.split("/")
filename = filepath[-1]
dot_position = filename.rfind(".")
ext = filename[dot_position:]
basename = filename[:dot_position]
if not ext in h_ext and not ext in c_ext:
  print("Not a C/C++ file.")
  vim.command("return")

# Which extension do we search for
ext_to_search = c_ext if ext in h_ext else h_ext

# Search for file
file_found = None
left_part = filepath[:-1]
current_source_sub = None
right_part = [basename]
while True:
  # Search a candidate
  subs = ["."]
  if current_source_sub is not None:
    # List subdirs
    base_dir_for_list = "/" + "/".join(left_part)
    subs = [name for name in os.listdir(base_dir_for_list) if os.path.isdir(os.path.join(base_dir_for_list, name))]

  for sub in subs:
    # Do not search in existing (already done at first iteration
    if sub != current_source_sub:
      candidate_path = "/".join(left_part + [sub] + right_part)
      for ext in ext_to_search:
        candidate_file = candidate_path + ext
        # print(candidate_file)
        if os.path.isfile(candidate_file):
          file_found = candidate_file
          # Stop search extensions
          break
    # Stop searching in subs
    if file_found is not None:
      break
  
  # Stop the whole search
  if file_found is not None:
    break

  # Unfortunetaly, we failed
  if 0 == len(left_part):
    break

  # Up to the next level
  if current_source_sub is not None:
    right_part.insert(0, current_source_sub)
  current_source_sub = left_part[-1]
  del left_part[-1]

if file_found is None:
  print("Failed to find paired file.")
else:
  vim.command("{} {}".format(vim.eval("a:open_command"),file_found))

endpython
endfunction
"  Mapping on shortcuts
map ,h :call SwitchHeaderImpl('e')<CR>
map ,H :call SwitchHeaderImpl('tab drop')<CR>

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

let g:rst_prefer_python_version = 'python3'

" Shortcuts to plugins
noremap <C-G> :YcmCompleter GoTo<cr>
map <C-I> :pyf /usr/share/clang/clang-format.py<cr>

" neovim tricks for old fucks like me
if has('nvim')
  nnoremap Y Y
endif
