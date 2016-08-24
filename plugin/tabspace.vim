if (exists("g:loaded_tabspace") && g:loaded_tabspace) || &cp
  finish
endif
let g:loaded_tabspace = 1

if !exists("g:tabspace_show_numbers")
	let g:tabspace_show_numbers = 0
endif

if !exists("g:add_tabspace_nerdtree_mappings")
	let g:add_tabspace_nerdtree_mappings = 0
endif

if !exists("g:add_tabspace_mappings")
	let g:add_tabspace_mappings = 0
endif

" Map of tab titles
let s:tabspaceData = {}
let s:tabspaceMapping = {}
let s:tabspaceIndex = 1000

function! Tabspace()
  let tablineText = ''
  for i in range(tabpagenr('$'))
    let tab = i + 1
    let windowNumber = tabpagewinnr(tab)
    let buflist = tabpagebuflist(tab)
    let bufferNumber = buflist[windowNumber - 1]
    let bufname = bufname(bufferNumber)

    let tablineText .= '%' . tab . 'T'
    let tablineText .= (tab == tabpagenr() ? '%#TabLineSel#' : '%#TabLine#')
	if g:tabspace_show_numbers
		let tablineText .= ' ' . tab .':'
	endif
    let tablineText .= ' ' . GetTabTitle(tab) . ' '

	" Add indicator to tab if any buffer in tab is modified
	let bufmodified = 0
	for b in buflist
		let bufmodified = bufmodified + getbufvar(b, "&mod")
	endfor
    if bufmodified
      let tablineText .= ' * '
    endif

  endfor

  let tablineText .= '%#TabLineFill#'
  return tablineText
endfunction

function GetTabTitle(tab)
	let tabspaceKey = ''
	if has_key(s:tabspaceMapping, a:tab)
		let tabspaceKey = s:tabspaceMapping[a:tab]
		let label = s:tabspaceData[tabspaceKey]['label']
		if !empty(label)
			return label
		endif
	endif
	let bufname = GetBufferName(a:tab)
	return (bufname != '' ? '['. fnamemodify(bufname, ':t') . '] ' : 'New space ')
endfunction

function! GetBufferNumber(tab)
    let winnr = tabpagewinnr(a:tab)
    let buflist = tabpagebuflist(a:tab)
    return buflist[winnr - 1]
endfunction

function GetBufferName(tabNumber)
	let bufferNumber = GetBufferNumber(a:tabNumber)
	return bufname(bufferNumber)
endfunction


function! RefreshTabspaces()
	set tabline=%!Tabspace()
endfunction

function! SetTabspaceLabel(name)
  let s:tabspaceData[t:tabspaceKey]['label'] = a:name
  call RefreshTabspaces()
endfunction

function! TabspaceCWD(workingDir)
	exe "cd " . a:workingDir
	let s:tabspaceData[t:tabspaceKey]['cwd'] = a:workingDir
endfunction

function! RefreshTabspaceWorkingDir()
	let tabcwd = s:tabspaceData[t:tabspaceKey]['cwd']
	if !empty(tabcwd)
		exe "cd " . tabcwd
	 endif
endfunction

function! TabspaceEnter()
	call InitializeTabspace()
	call RefreshTabspaceWorkingDir()
endfunction

function! InitializeTabspace()
	if !exists("t:tabspaceKey")
		let s:tabspaceIndex = s:tabspaceIndex + 1
		let t:tabspaceKey = s:tabspaceIndex
		let s:tabspaceData[t:tabspaceKey] = {
			\ 'cwd' : getcwd(),
			\ 'label': ''
		\}
	endif
	let s:tabspaceMapping[tabpagenr()] = t:tabspaceKey " TODO, this will only handle the current tab.  Need to cleanup other tabs
endfunction

if g:add_tabspace_nerdtree_mappings

	function! TabspaceNerdTreeCWD()
		let current_file = g:NERDTreeFileNode.GetSelected()

		if current_file == {}
			return
		else
			exe ':TabspaceCWD ' . current_file.path.str()
		endif
	endfunction

	nnoremap tg :call TabspaceNerdTreeCWD()<CR>
endif

" This is where the magic happens
au TabEnter * :call TabspaceEnter()

"Commands
command! -nargs=1 TabspaceLabel call SetTabspaceLabel(<f-args>)
command! -nargs=1 TabspaceCWD call TabspaceCWD(<f-args>)

"Shortcuts
if g:add_tabspace_mappings
	nnoremap tj  :tabnext<CR>
	nnoremap tk  :tabprev<CR>
	nnoremap tt  :tabnew<CR>
	nnoremap td  :tabclose<CR>
	nnoremap tr  :TabspaceLabel<Space>
endif

"Setup for the first tab
call InitializeTabspace()
call RefreshTabspaces()

