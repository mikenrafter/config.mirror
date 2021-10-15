" a really cool .vimrc --> :set foldmethod=marker foldmarker={,} foldlevel=0" plugins {-
" plugins
"set rtp+=~/.vim/bundle/Vundle.vim
"call vundle#begin()
"Plugin 'gmarik/Vundle.vim'
"-}
" colors {-
" implicit try & catch, least favored first
silent! color peachpuff
silent! color desert
silent! color delek
silent! color pablo
silent! color torte
silent! color darkblue
if has("gui_running")
	silent! color slate
	silent! color desert
end

set background=dark

" I hear doing it this exact way fixes performance, idk
syntax on
set synmaxcol=200
syntax on
"-}
" highlighting {-
" change vertical splic color
hi VertSplit ctermbg=black ctermfg=darkgrey guifg=black guibg=darkgrey
" enable highlighting based on current line
"set cursorline " has been causing performance issues
" highlight current line number
hi CursorLineNr cterm=bold ctermfg=blue gui=bold guifg=blue
" highlight current line instead of underline
hi CursorLine term=none cterm=none ctermbg=234 gui=none guibg=black
hi CursorColumn term=none ctermbg=234 gui=none guibg=black
" color other line numbers gray
hi LineNr ctermfg=gray guifg=gray

" spelling
hi SpellBad ctermfg=red ctermbg=black cterm=underline term=underline gui=underline guifg=red guibg=black
hi SpellRare ctermfg=yellow ctermbg=black cterm=underline term=underline gui=underline guifg=red guibg=black
hi SpellCap ctermfg=blue ctermbg=black cterm=underline term=underline gui=underline guifg=blue guibg=black

" dim whitespace indicators
" 241 is darker than darkgray, but still noticeable and lighter than my bg
" nvim likes to be special!
hi Whitespace ctermfg=238 ctermbg=235 guifg=black
"hi Whitespace ctermfg=241 ctermbg=235 guifg=darkgray
" regular vim mode
hi SpecialKey ctermfg=241 ctermbg=235 guifg=darkgray
" changes the color of space indents
hi Indents ctermfg=245 ctermbg=none cterm=bold
" change color of escaped characters
hi Escaped ctermfg=red ctermbg=none cterm=bold
" really long lines, past the 80 mark is this color
hi Long ctermbg=235 cterm=none
"hi Long ctermbg=236 cterm=none
" color at line 80
hi ColorColumn ctermbg=236
" color the tabline bg the same as the bg
hi TabLine ctermfg=white ctermbg=237 term=none cterm=none
hi TabLineSel ctermfg=blue ctermbg=black
hi TabLineFill ctermfg=black ctermbg=black

" selection
" fixes comment highlights
hi! Visual cterm=bold ctermbg=241 ctermfg=white
"-}
" basic settings {-
set nocompatible                " Use Vim defaults instead of 100% vi compatibility
set backspace=indent,eol,start  " more powerful backspacing

" Now we set some defaults for the editor
set history=50                  " keep 50 lines of command line history
set undolevels=3000             " ensure you can go back!
set ruler                       " show the cursor position all the time
set showcmd laststatus=0        " vim kinda sucks without it

" highlight current text area
set cursorline cursorcolumn

" Suffixes that get lower priority when doing tab completion for filenames.
" These are files we are not likely to want to edit or read.
set suffixes=.bak,~,.swp,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc


" Set extra options when running in GUI mode
if has("gui_running")
" remove tool-bar
" remove menu-bar
	set guioptions-=T
	set guioptions-=m
" remove GUI tabs
"	set guioptions-=e
" remove scrollwheels
	set guioptions-=r
	set guioptions-=R
	set guioptions-=l
	set guioptions-=L
	set guioptions-=b
	set guioptions-=h

	set t_Co=256
	set guitablabel=%M\ %t
	" Make shift-insert work like in Xterm
	map <s-Insert> <middleMouse>
	map! <s-Insert> <middleMouse>
end

"-}
" set {-
" -- UI
" regex for seeing if a character is escaped
let escaped = '\(\([^\\]\|^\)\(\\\\\)*\)\@<=\\'

" filetype and indentation
filetype plugin indent on
set autoread smartindent noexpandtab softtabstop=0 tabstop=4 shiftwidth=4

" folding {-
" maximum fold level
" setlocal is used for folding elsewhere, this is the default
set foldnestmax=10 foldmarker={,} foldmethod=indent

" enable folding # disabled, is enabled in autocommand, only enabled when file
" size is reasonable
"set foldenable
"-}

" central backup-type file location
set directory^=$HOME/.vim/swaps//
set backupdir^=$HOME/.vim/backup//
set undodir   =$HOME/.vim/undos//,.
set undofile
set backupskip^=*~,*.swp,*.swo

" let lines wrap offscreen
" line wrap
" wrap & break on words
" indent line wraps
set display+=lastline wrap lbr breakindent
" column to insert \n on
" some other chars to break on
" only insert \n on text width inside comments
set tw=80 breakat+='=\'()[]{}\ ' formatoptions-=t
" used to have this dynamic, that was a huge performance issue
set colorcolumn=80

" tab HL &:
" Specify the behavior when switching between buffers
try
	" ?,?,?
	" always show all tabs
	set switchbuf=useopen,usetab,newtab stal=2
endt

" rulers
" Height of the command bar
set ruler cmdheight=1
" set line number config
" Add a bit extra margin to the left
set nu rnu numberwidth=1

" Configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" Ignore case when searching
" When searching try to be smart about cases
" Makes search act like search in modern browser
" Highlight search results
" For regular expressions turn magic on
set ignorecase smartcase incsearch hlsearch magic

" Don't redraw while executing macros (good performance config)
set lazyredraw

" Show matching brackets when text indicator is over them
" How many tenths of a second to blink when matching brackets
set showmatch mat=1

" No annoying sound on errors
set noerrorbells t_vb=

" remove unreasonable timeouts
set ttimeoutlen=10


" Set utf8 as standard encoding and en_US as the standard language
set encoding=utf8

" Use Unix as the standard file type
set ffs=unix,mac,dos



" " " " " " " " " " " " " " "

" spell check
set spell

" enable mouse support inside insert, visual, and command mode
set mouse=a
" set mouse=ivc

" visual tab completion
set wildmenu

" ignore unreadable files
"set wildignore=*.swp,*.bak,*.bkp,*~ " backup files -- these are now set to low priority mode
set wildignore+=*.i,*.o,*.?i,*.?o,*.?c,*.??c " compiled files
set wildignore+=*.??g,*.gif,*.bmp,*.ico " image files
set wildignore+=*.part " other
set wildignore+=*.Appimage,*.bin,*.exe " that last one makes you want to cringe, doesn't it
" ignore unnotable folders
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
"-}
" mappings {-
let mapleader = ","
" visual {-
" disable visualbinds, incredibly important | functions-visualbinds
vm <silent> <esc> :call VisualBinds(0)<cr>

" quick select
vnor <m-up>    gk
vnor <m-down>  gj
vnor <m-left>  h
vnor <m-right> l

vnor <s-up>      k
vnor <s-down>    j
vnor <m-s-up>    k
vnor <m-s-down>  j
vnor <m-s-left>  g^
vnor <m-s-right> g$

vnor <m-c-left>  <c-left>
vnor <m-c-right> <c-right>
vnor <s-left> g^
vnor <s-right> g$


" aliases
vnor ; :

" indentation
vnor <s-tab> <gvohoh
vnor <tab> >gvolol

" folds
vnor <space> za

" save compatibility
vnor <silent> <c-s> :w<cr>

" move to beginning/end of line
vnor B 0
vnor E $

vnor w iw

" copy selection (rounded to full lines) to system clipboard
vnor     Y :call YankNext()<cr>gvy
vnor <c-y> :call YankNext()<cr>gvy
vnor <c-c> :call YankNext()<cr>gvy
" trying w/out folding stuff, not sure how it'll fair
"vnor <c-y> :call YankNext()<cr>zngvyzm
"vnor <c-c> :call YankNext()<cr>zngvyzm

vnor <silent> j gj
vnor <silent> k gk
vnor <silent> <down> gj
vnor <silent> <up> gk
vnor <silent> <home> g^
vnor <silent> <end> g$
vnor J j
vnor K k
vnor <s-left> g^
vnor <s-right> g$
vnor H g0
vnor L g$
"-}
" normal {-
" better insert shortcuts
nnor I 0i
" you forgot that <c-i> == <tab>! Think of another, perhaps <m-i>?
"nnor <c-i> ^i
nnor <m-i> ^i

" quick select
nnor <m-right> vl
nnor <m-up>    vk
nnor <m-down>  vj
nnor <m-left>  vh


nnor <c-v> :call VisualBinds(0)<cr><c-v>
nnor <s-v> :call VisualBinds(0)<cr><s-v>
nnor v     :call VisualBinds(0)<cr>v

" aliases
nnor ; :

" reload vimrc
" $MYVIMRC was removed in modern nvim
nnor <silent> <leader>r :source ~/.vimrc<cr>

" toggle spellcheck
nnor <silent> <leader>/ :setlocal spell!<cr>

" indentation
" nm is required, nnor will not work here, no clue why
nm <c-s-tab> [{<%
nm <c-tab> ]}>%
nm <s-tab> <%
nm <tab> >%

" block navigation
nnor <c-up> [{
nnor <c-down> ]}

" easy file-link following
nnor <c-f> <c-6>

" insert single character
nnor <s-s> i <esc>r
nnor <m-r> i <esc>r

" last change
nnor - `.

" move up and down across wrapped lines easier
nnor <silent> j gj
nnor <silent> k gk
nnor <silent> <down> gj
nnor <silent> <up> gk
nnor <silent> <home> g^
nnor <silent> <end> g$
nnor J j
nnor K k
nnor <s-left> g^
nnor <s-right> g$
nnor H g^
nnor L g$
nnor <s-up> k
nnor <s-down> j

" move to beginning/end of line
nnor B 0
nnor E $
nnor cB c0
nnor dB d0
nnor yB y0
nnor cE c$
nnor dE d$
nnor yE y$

" paste system clipboards
nnor <silent>    <m-p> "+P
nnor <silent>  <m-s-p> "*P
nnor <silent>    <m-v> "+P
nnor <silent> <middle> "*P
"nnor <silent>  <c-s-v> "+P " doesn't work, terminal overlap
nnor <silent>    <c-p> "+P

" easier redo
nnor U <c-r>

" date/time
nnor <F3> i<C-R>=strftime("%Y-%m-%d %a %I:%M %p")<CR><Esc>

" spell check fixes for word
nnor \ z=

" select all
nnor <c-a> ggvG$
nnor <leader>a ggvG$

" Remove the Windows ^M - when the encodings gets messed up
nor <leader>gq mmHmt:%s/<c-v><cr>//ge<cr>'tzt'm

" first non whitespace character
nnor <leader>1 :tabn 1<cr>
nnor <leader>2 :tabn 2<cr>
nnor <leader>3 :tabn 3<cr>
nnor <leader>4 :tabn 4<cr>
nnor <leader>5 :tabn 5<cr>
nnor <leader>6 :tabn 6<cr>
nnor <leader>7 :tabn 7<cr>
nnor <leader>8 :tabn 8<cr>
nnor <leader>9 :tabn 9<cr>

" toggle between this and the last accessed tab
nnor <silent> <leader><space> :exe "tabn ".g:lasttab<cr>

" new tab
nnor <silent> <leader>m :tabnew<cr>
nnor <silent> <c-t> :tabnew<cr>
"nnor <silent> <c-s-n> :tabprev<cr>
nnor <silent> <c-n> :tabprev<cr>
nnor <silent> <c-e> :tabnext<cr>
nnor <silent> <c-pagedown> :tabnext<cr>
nnor <silent> <c-pageup> :tabprev<cr>
nnor <silent> <leader>n :-tabmove<cr>
nnor <silent> <leader>N :-tabmove<cr>
nnor <silent> <leader>e :+tabmove<cr>
nnor <silent> <leader>E :+tabmove<cr>

nnor <silent> <leader> :noh<cr>

" how many lines from top/bottom before screen scrolls with cursor
"nnor <leader><down> :set so-=5<cr><cr>
"nnor <leader><up> :set so+=5<cr><cr>
set so=10

" easy line modifications
nnor <leader>O O<esc>
nnor <leader>o o<esc>
nnor <leader><del> A<del><esc>
nnor <leader><backspace> 0i<backspace><esc>

" compilations
nnor <silent> <leader>c :call Launch('')<cr>
nnor <silent> <leader><leader>c :call Launch('&')<cr>

" write variations
nnor <leader>w :w<cr>
nnor <leader><leader>w :w!<cr>
nnor <leader>W :W<cr>
nnor <leader><leader><leader> :wq<cr>
nnor <silent> <c-s> :w<cr>

" quit variations
nnor <c-q> :q<cr>
nnor <leader>q :q<cr>
nnor <leader><leader>q :q!<cr>

" toggle yank to system clipboard
nnor <leader><leader> :call YankNext()<cr>

nnor <leader>s :vs<cr><c-w>w
nnor <leader><leader>s :split<cr><c-w>w

nnor <leader><leader>. :e!<space>
nnor <leader>. :e<space>
"nnor <leader>e :e<space><up>
"nnor <leader><leader>e :e!<space><up><cr>

" collapse all folds
nnor <silent> <cr> :setlocal foldlevel=0<cr>
" expand all folds
nnor <silent> \| zR
nnor <silent> <c-cr> zR
" toggle folds
nnor <silent> = zA
nnor <silent> <c-space> zA
nnor <silent> <s-space> zA
nnor <silent> <space> za

" no EX mode!
nnor Q @q
"-}
" insert {-

" control-backspace
inor <c-h> <c-w>

" completions
inor <silent> <tab><tab> <c-o>:call Completions()<cr><c-n>

" more deletions
inor <s-bs> <c-o>db
inor <s-del> <c-o>de

" quick select
inor <silent> <m-right> <c-o>:call VisualBinds(1)<cr><c-o>vl
inor <silent> <m-up>    <c-o>:call VisualBinds(1)<cr><c-o>vk
inor <silent> <m-down>  <c-o>:call VisualBinds(1)<cr><c-o>vj
inor <silent> <m-left>  <c-o>:call VisualBinds(1)<cr><c-o>vh

" reasonable scroll wheel functionality
" or, mouse=a
" inor <s-scrollwheelup> <c-o>4gk
" inor <scrollwheelup> <c-o>gk
" inor <s-scrollwheeldown> <c-o>4gj
" inor <scrollwheeldown> <c-o>gj

inor <silent> <s-right> <c-o>g$<c-o>a
inor <silent> <s-left> <c-o>g^
" too complex to solve with simple <c-o>b & e
inor <silent> <c-right> <c-right>
inor <silent> <c-left> <c-left>
" move up and down across wrapped lines easier
inor <silent> <s-down> <down>
inor <silent> <s-up> <up>
inor <silent> <down> <c-o>gj
inor <silent> <up> <c-o>gk

" paste system clipboards
inor <silent> <middle> .<bs><c-o>"*p
inor <silent>    <c-v> .<bs><c-o>"+p
"inor <silent>  <c-s-v> <c-o>:set paste<cr><c-r>*<c-o>:set nopaste<cr>
inor <silent>    <m-p> .<bs><c-o>P


inor <silent> <m-c-v> <c-o><c-v>
inor <silent> <m-s-v> <c-o><s-v>
inor <silent> <m-v> <c-o>v
inor ;<up> <c-o>:<up>
inor ;; <c-o>
inor ;u <c-o>u
inor ;U <c-o><c-r>
inor ;o <c-o>o
inor ;O <c-o>O
inor ;d <c-o>dd
inor ;= <c-o>z=
inor ;= <c-o>z=
inor ;/ <c-o>z=
inor ;\ <c-o>z=

inor :<up> <c-o>:<up>

inor <leader><leader> <c-o>
inor <leader>u <c-o>u
inor <leader>U <c-o><c-r>
inor <leader>o <c-o>o
inor <leader>O <c-o>O
inor <leader>d <c-o>dd
inor <leader>= <c-o>z=
inor <leader>= <c-o>z=
inor <leader>/ <c-o>z=
inor <leader>\ <c-o>z=

" date/time
inor <F3> <C-R>=strftime("%Y-%m-%d %a %I:%M %p")<CR>

" ctrl s saves
inor <silent> <c-s> <c-o>:w<cr>
inor <silent> <c-t> :tabnew<cr>
"-}
" term {-
tnor <c-o> <c-\><c-n>
tnor ::    <c-\><c-n>
tnor ;;    <c-\><c-n>
"-}
" operator-pending {-
" leave w as onor?? Perhaps, may cause conflict later
om w iw

om E $
om B 0


" visual movement
onor j gj
onor k gk
onor <down> gj
onor <up> gk

" movement aliases
om <home> g^
om <end> g$
om J j
om K k
om <s-left> g^
om <s-right> g$
om H g^
om L g$
om <s-up> k
om <s-down> j
"-}
" global? {-
nor <silent> <c-t> :tabnew<cr>
" f1's near esc key, too many accidental presses
nor <silent> <f1> <esc>
" if you really need help, you can type :help, or <f2>
nor <silent> <f2> <f1>
set pastetoggle=<f2>
"-}

"-}
" functions {-
fun! UnComplete() "{-
	silent! iunmap <tab>
	silent! iunmap <space>
	silent! iunmap <cr>
	silent! iunmap <esc>
	silent! iunmap <left>
	silent! iunmap <right>
	silent! iunmap <up>
	silent! iunmap <down>
	silent! iunmap <c-o>
	inor <silent> <tab><tab> <c-o>:call Completions()<cr><c-n>
endf "-}
fun! Completions() "{-
	iunmap <tab><tab>
	inor <tab>   <c-n>

	inor <c-o>   <c-o>:call UnComplete()<cr><c-o>
	inor <space> <c-o>:call UnComplete()<cr><space>
	inor <cr>    <c-o>:call UnComplete()<cr>
	inor <esc>   <c-o>:call UnComplete()<cr>

	inor <left>     <left><c-o>:call UnComplete()<cr>
	inor <right>     <right><c-o>:call UnComplete()<cr>

	inor <up>     <c-p>
	inor <down>     <c-n>
endf "-}
fun! Nop(a) "{-
	return
endf "-}
fun! FoldMode() "{-
	" restore foldmode, do not re-evaluate
	try
		if len(b:foldmode) == 2
			exe 'set foldmethod='.b:foldmode[0].' foldmarker='.b:foldmode[1]
			return
		end
	catch
	endtry
	" evaluate, storing in foldmode happens elsewhere
	" default
	setlocal foldmethod=indent
	" change to file's directory, for expansion
	call Cdfile(1)
	
	" get vars for use later
	let l:file     = expand("%:p")
	let l:folder   = expand("%:p:h")
	
	" stop short if file is a script
	let l:continue = 1
	for extension in g:scriptExtensions
		let l:ext = '.'.extension
		if l:file[-strlen(l:ext):] == l:ext
			let l:continue = 0
			break
		end
	endfor
		
	if l:continue
		for mapping in g:fakeOrgMode
			" only evaluate once
			let l:expanded = expand(mapping[0])
			"echo l:expanded
			"silent! exe '!notify-send "'.substitute(l:expanded, "\n", '\\n', 'g').' '.expand("%:p:h").'"'
			" if file is exactly equal
			let l:matches = 0
			if l:file == l:expanded
				let l:matches = 1
			" support for expansion, and for folders
			else
				let l:expanded = split(l:expanded, '\n')
				for item in l:expanded
					" if a folder
					if mapping[0][-1:] == '/'
						" -2, because -1 does nothing in this case, perhaps someone
						" thought it a good idea to implement indexes like
						" append-mode is in vim?? I have no idea.
						if stridx(l:folder, item[:-2]) >= 0
							let l:matches = 1
							break
						end
					" if not a folder
					else
						if item == l:file
							let l:matches = 1
							break
						end
					end
				endfor
			end
			" if any of the above are true
			if l:matches
				" don't execute on reloading of vimrc
				" if markerPair is present (see above)
				if len(mapping) > 1 && mapping[1] != ''
					execute 'setlocal foldmarker=' . mapping[1]
				end
				setlocal foldmethod=marker
				call Cdfile(0)
				" don't loop when not necessary, implicit else
				break
			end
		endfor
	end
	call Cdfile(0)
	" save foldmode
	let b:foldmode = [&foldmethod, &foldmarker]
endf "-}
"fun! FoldExpr(lnum) "{-
"	let l:l = getline(a:l)
"	let l:n = getline(a:l+1)
"	if l:l[0] == "\"\t\""
"		return 1
"	elseif l:l =~ '^\\s*$' && l:n =~ '\\S'?'<1':1
"		return 1
"	endif
"	return 0
"	" getline(v:lnum)[0]==\"\\t\"\|\|\(getline(v:lnum)=~'^\\s*$'&&getline(v:lnum+1)=~'\\S'?'<1':1\)
"endf "-}
fun! Cdfile(env) "{-
	try
		try
			silent! echo a:env
			let l:env = a:env
		catch
			let l:env = 1
		endtry
		if env
			exe 'let g:old_cwd="' . getcwd() . '"'
			lcd %:p:h
		else
			exe 'lcd "' . g:old_cwd . '"'
			let g:old_cwd=''
		end
		return 1
	catch
		return 0
	endt
endf
"-}
fun! Launch(extra) "{-
	try
		silent! echo a:extra
		let l:extra = a:extra
	catch
		let l:extra = ''
	endtry
	" change to files directory
	if !Cdfile(1)
		return 0
	end
	if filereadable('makefile') || exists('Makefile')
		normal :!make
	elseif filereadable('CmakeLists.txt')
		normal :!cmake
	else
		" identify potential shebang
		let l:bang = getbufline(bufnr(@%), 1, 1)[0]
		let l:line = l:bang
		let l:binary = '' " failsafe
		# more launch {
		if match(l:bang, '^[^a-zA-Z\d]{2}') == 0 " if first 2 characters are symbols
			" shebang nonexistant, so ignore for other shebang checks
			let l:bang = ''
		else
			let l:bang = l:bang[2:]
		end
		" if shebang potentially exists, determine what the executable is
		if strchars(l:bang)
			let l:len = match(l:bang, g:escaped . '\s')
			if l:len == -1
				let l:len = strchars(l:bang)
			end
			" get binaries length
			let l:binlen = max([0, match(l:bang, '[^a-zA-Z\d-]')])
			" if need be, fix
			if l:binlen == 0
				let l:binlen = l:len - 1
			end
			" start at beginning of binary, end at end
			let l:bang = l:bang[ match(l:bang, '^[a-zA-Z\d-]') : ]
			let l:binary = expand(l:bang[ : l:binlen ])

		end
		let g:file = expand("%")
		" run if shebang or pseudo shebang
		if executable(l:binary) || l:line[0] == &commentstring[0]
			let g:compile = l:bang
			" if is proper shebang, let shebang interpreter handle it (for
			" multiline shebangs mostly)
			if l:line[:2] == '#!/'
				silent! execute '!chmod +x ' . expand(@%)
				let g:compile = './' . expand(@%)
				let g:file = ''
			end
		" check for file extension
		elseif has_key(g:filetypes, expand('%:e', 1))
			let g:compile = get(g:filetypes, expand('%:e', 1))
		" check for filetype
		elseif has_key(g:filetypes, &filetype)
			let g:compile = get(g:filetypes, &filetype)
		" try filetype as command
		else
			let g:compile = &filetype
		end
		let g:dir = expand("%:p:h")
		" if no file, then let compiler alone handle it
		" add space if not the case (hey, that rhymes!)
		if g:file != ''
			let g:file = ' ' . g:file
		end
		let g:compile = escape(g:compile . g:file . ' ' . extra, '"<>')
		tabnew | term exec fish
		call feedkeys("i cd " . escape(g:dir, '"<>') . "\<cr> " . g:compile . "\<cr>")
		call InsertEnter()
	end
	call Cdfile(1)
endf "-}
fun! BackupMode() "{-
	call Cdfile(1)
	" don't make a backup if file is humongous, or if is tracked by git, that
	" is, if git exists on the system. Still use undofile, however | set
	let l:output = system(expand('git ls-files --error-unmatch %', 1))
	if getfsize(expand(@%)) > g:largefile || ( v:shell_error == 1 && executable('git') )
		" turn backup off
		set nobackup
		set nowb
		set noswapfile
	else
		" turn backup on
		set backup
		set wb
		set swapfile
	end
	call Cdfile(0)
endf "-}
fun! IndentGuides() "{-
	" if b:escaped is unset, then set all values, otherwise, leave be
	" don't bother checking others, since in normal circumstances these
	" values are all set together

	try
		call Nop(b:escaped)
	catch

		" visual chars
		try
			silent! set list lcs=tab:│\ \ ,trail:░,space:·,conceal:…,extends:»,precedes:«
			silent! set showbreak=\ │\ \ 
		catch
			set list lcs=tab:\|\ \ ,trail: ,space:_,conceal:+,extends:@,precedes:@
			silent! set showbreak=\ \|\ \ 
		endt

		" escaped whitespace or newlines
		let b:escaped = matchadd('Escaped', g:escaped . '\(\s\|$\)')

		" really long lines
		let b:long = matchadd('Long', '\%' . &colorcolumn . 'v.*')

		
		let l:padding = 2
		" every 4th space in a performant way
		" 1 through colorcolumn, use padding
		for i in range(1, &colorcolumn/&tabstop-l:padding*2-1)	" apply right side padding and loop through
			" preceeding space requirement
			let l:pre = '\(' . repeat(' ', &tabstop/2) . '\)\@<=\%'
			" every tabwidth chars, with left padding
			let l:line = &tabstop*(l:padding + i)
			" add the indent guides
			let l:indents = matchadd('Indents', l:pre . l:line . 'c ')
			" local variable because using an array caused issues
		endfor
		" highlight beginning tab characters, highlighting every 4 spaces was really bad for performance
		let l:indents = matchadd('Indents', '^\t\+')
	endt
endf "-}
fun! YankNext() "{-
	aug yanknext
		au!
		au TextYankPost * call setreg('+', v:event.regcontents) | echom 'yanked to system keyboard' | silent! au! yanknext
	aug END
endf "-}
fun! TrimTrailLine() "{-
	let save_cursor = getpos(".")
	let old_query = getreg('/')
	silent! %s/\s\+$//e
	call setpos('.', save_cursor)
	call setreg('/', old_query)
endf "-}
fun! VisualBinds(state) "{-
	try
		silent! echo a:state
		let l:state = a:state
	catch
		let l:state = 1
	endtry
	if l:state  " <esc> is set to undo visualbinds as well | mappings-visual
		vnor k       <esc>gk
		vnor j       <esc>gj
		vnor h       <esc>h
		vnor l       <esc>l

		vnor <up>    <esc>g<up>
		vnor <down>  <esc>g<down>
		vnor <left>  <esc><left>
		vnor <right> <esc><right>
	else
		vnor k       gk
		vnor j       gj
		vnor h       h
		vnor l       l

		vnor <up>    g<up>
		vnor <down>  g<down>
		vnor <left>  <left>
		vnor <right> <right>
	end
endf "-}

fun! FocusGained() "{-
	if g:blurinsert == 1
		" retain position across focus changes
		" exit c-o mode
		call feedkeys("\<esc>")
	end
endf "-}
fun! FocusLost() "{-
	" retain position across focus changes
	if mode() == 'i'
		let g:blurinsert = 1
		" keep indent (.<bs>)
		" enter c-o mode
		" TODO: make all keybinds preserve auto-tab characters on line-switch
		call feedkeys("\<c-o>")
	else
		let g:blurinsert = 0
	end
endf "-}
fun! CursorHold() "{-
	if mode() == 'n'
		call VisualBinds(0)
	end
endf "-}
fun! CursorMoved() "{-
	call UnComplete()
endf "-}
fun! BufRead() "{-
	" if file starts less than 500kb (1k(b) * 500)
	" prevent CPU overloading
	if getfsize(expand(@%)) < g:largefile
		call FoldMode()
		setlocal foldlevel=0 foldminlines=0 foldenable
	end
	set autoread smartindent noexpandtab softtabstop=0 tabstop=4 shiftwidth=4
endf "-}
fun! BufEnter() "{-
	" restore path, for Cdfile
	exe 'set path=' . g:defpath . ',' . expand("%:p:h") . '/**'
	" highlight indents
	call IndentGuides()
	" fold things
	call FoldMode()
endf "-}
fun! BufLeave() "{-
	"setlocal foldlevel=1
endf "-}
fun! InsertEnter() "{-
	set timeout timeoutlen=300
endf "-}
fun! InsertLeave() "{-
	set timeout timeoutlen=600
	call UnComplete()
endf "-}
fun! SwapExists() "{-
	" no windows crap here!
	if !(has('win32') || has('win16'))
		if system('cmp ' . v:swapname . expand(@%))
			let v:swapchoice = 'd'
			" return
		end
	end
endf "-}

"-}
" ex functions {-
" :W sudo save
" (useful for handling the permission-denied error)
command! W execute 'w !sudo tee % > /dev/null' <bar> edit!
" :E opens current dir
command! E execute 'e ' . expand("%:p:h")
"-}
" init {-

" what to consider a large file size in bytes
let g:largefile = 1000 * 500

" ensure swaps, backups & undofiles are viable
for dir in [&undodir, &backupdir, &directory]
	let folder = split(dir, ',')
	if !isdirectory(expand(folder[0]))
		call mkdir(folder[0], 'p')
	end
endfor
unlet folder

" for retaining focus position
let g:blurinsert = 0

" reopen last file if no arguments, and buffer empty
if argc() == 0 && expand(@%) == ""
	call feedkeys(":e \<up>\<cr>")
end

" tab to go back to, prevent error
let g:lasttab = 1
" remember path before modification, for gf command
let g:defpath = &path
" set previous directory to nothing / $HOME
let g:old_cwd=""
" mappings used by Launch()
let syntaxmapping={'fish': 'bash'}
let filetypes={'c': 'gcc', 'sh': 'bash', 'hs': 'ghc', 'html': "$BROWSER", 'xml': "$BROWSER", 'json': "$BROWSER", 'rust': 'rustc', 'sql': 'sqlite3'}

" scripts, by default, will be ignored by fakeOrgmode
let scriptExtensions = [ 'sh', 'fish', 'py', 'nim', 'zsh' ]
" fold some config files other ways
" [['glob/path/or/containing/dir', 'foldnow,stopfold'],['second param for each item is optional']]
let g:fakeOrgMode = [['~/.config/'],['~/data/configs/'], ['~/.?*'],['~/.?*/'], ['~/*.conf']] ", ['~/.vimrc', '{-,-}']]
" any dotfile under ~
" any file in a dotfolder under ~
" any .conf file

" use insertleave as an initial normal-mode entry hook too
call InsertLeave()

" set foldmode after vimrc restarts
call FoldMode()

" remove highlights, mostly for restarts or session restores
nohlsearch
"-}
" auto commands {-
aug modes "{-
	au!
	" buffer read, enter & leave
	" buffer enter commands
	" buffer leave commands
	au BufRead * :call BufRead()
	au BufEnter * :call BufEnter()
	au BufLeave * :call BufLeave()
	
	" manage cursorhold, this is dependent upon the mode
	au CursorHold * :call CursorHold()
	" enter and exit insert mode commands
	au InsertLeave * :call InsertLeave()
	au InsertEnter * :call InsertEnter()
aug END
"-}
aug general "{-
	au!

	" remember previous tab
	au TabLeave * let g:lasttab = tabpagenr()

	" keep spellchick enabled
	" au BufNew * setlocal spell
	
	" use proper backup method
	au BufEnter * :call BackupMode()

	" deal with swapfiles, when they don't differ
	au SwapExists * :call SwapExists()


	" cursor move commands
"	au CursorMoved * :call CursorMoved()

	" set proper fold mode, marker for config files, and some frequent folders
	" otherwise, indent
	" moved to bufRead
	"au BufEnter * :call FoldMode()
	
	" -- file interactions
	" update with external changes
	set autoread
	au FocusGained,BufEnter * checktime

	" upon refocus
	au FocusGained * silent! :call FocusGained()
	" upon unfocus
	au FocusLost * silent! :call FocusLost()
	
	" return to starting dir
	au BufEnter * silent! :call Cdfile(0)
aug END "-}
aug saveposition "{-
	au!
	" remember position in file
	au BufWritePre,BufLeave,FocusLost,BufUnload *
	\ silent! if &ft !='#commit' | exe "normal! m\"" | end
	" restore  position in file
	au BufEnter,BufReadPost * silent!
	\ exe "normal! g`\""
aug END " -}
" -}
