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

if !exists("g:tabspace_tab_highlight")
    let g:tabspace_tab_highlight = "TabspaceGray"
endif
if !exists("g:tabspace_selected_tab_highlight")
    let g:tabspace_selected_tab_highlight = "TabspaceBlack"
endif
if !exists("g:tabspace_fill_highlight")
    let g:tabspace_fill_highlight = "TabspaceGray"
endif
if !exists("g:tabspace_divider")
    let g:tabspace_divider = "|"
endif
if !exists("g:tabspace_excluded_buffer_names")
    let g:tabspace_excluded_buffer_names = ['NERD_Tree']
endif
if !exists("g:named_tabspaces")
    let g:named_tabspaces = {}
endif

" Map of tab titles
let g:tabspaceData = {}
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
    let tabHighlight = GetTabHighlight(tab)

    let tablineText .= '%' . tab . 'T'
    let tablineText .= '%#' . tabHighlight .  '#'
    if g:tabspace_show_numbers
        let tablineText .= ' ' . tab .':'
    endif
    let tablineText .= ' ' . GetTabTitle(tab)

    " Add indicator to tab if any buffer in tab is modified
    let bufmodified = 0
    for b in buflist
        let bufmodified = bufmodified + getbufvar(b, "&mod")
    endfor
    if bufmodified
      let tablineText .= ' *'
    endif

    let tablineText .= ' %#' . g:tabspace_fill_highlight . '#'
    let tablineText .= g:tabspace_divider

  endfor

  let tablineText .= '%#' . g:tabspace_fill_highlight . '#'
  return tablineText
endfunction

function GetTabHighlight(tab)

    if !has_key(s:tabspaceMapping, a:tab)
        " This can get called during tab creation before we've had a chance to
        " populate all of the tab data
        return g:tabspace_tab_highlight
    endif
    let tabspaceKey = s:tabspaceMapping[a:tab]
    let selected = a:tab == tabpagenr()
    if (selected)
        let highlight = g:tabspaceData[tabspaceKey]['activeColor']
        if empty(highlight)
            let highlight = g:tabspace_selected_tab_highlight
        endif
    else
        let highlight = g:tabspaceData[tabspaceKey]['inactiveColor']
        if empty(highlight)
            let highlight = g:tabspace_tab_highlight
        endif
    endif
    return highlight
endfunction

function GetTabTitle(tab)
    let tabspaceKey = ''
    if has_key(s:tabspaceMapping, a:tab)
        let tabspaceKey = s:tabspaceMapping[a:tab]
        let label = g:tabspaceData[tabspaceKey]['label']
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

function! SetTabspaceLabel(label)
  let g:tabspaceData[t:tabspaceKey]['label'] = a:label
  call RefreshTabspaces()
endfunction

function! TabspaceCWD(workingDir)
    exe "cd " . a:workingDir
    let g:tabspaceData[t:tabspaceKey]['cwd'] = a:workingDir
endfunction

function! RefreshTabspaceWorkingDir()
    let tabcwd = g:tabspaceData[t:tabspaceKey]['cwd']
    if !empty(tabcwd)
        exe "cd " . tabcwd
     endif
endfunction

function! TabspaceEnter()
    call InitializeTabspace()
    call RefreshTabspaceWorkingDir()
    call RefreshTabspaces()
endfunction

function! TabspaceBufAdd(buf)
	if has_key(g:tabspaceData, t:tabspaceKey)
		let g:tabspaceData[t:tabspaceKey]['buffers'] = filter(g:tabspaceData[t:tabspaceKey]['buffers'], 'v:val != a:buf')
	endif
    call add(g:tabspaceData[t:tabspaceKey]['buffers'], a:buf)
endfunction

function! TabspaceBufDelete(buf)
    let idx = index(g:tabspaceData[t:tabspaceKey]['buffers'], a:buf)
    if idx >= 0
        call remove(g:tabspaceData[t:tabspaceKey]['buffers'], idx)
    endif
endfunction

function! InitializeTabspace()
    if !exists("t:tabspaceKey")
        let s:tabspaceIndex = s:tabspaceIndex + 1
        let t:tabspaceKey = s:tabspaceIndex
        let g:tabspaceData[t:tabspaceKey] = {
            \ 'cwd' : getcwd(),
            \ 'label': '',
            \ 'activeColor' : '',
            \ 'inactiveColor' : '',
            \ 'buffers' : []
        \}

        let current = tabpagenr('$')
        while current > tabpagenr()
            let s:tabspaceMapping[current] = s:tabspaceMapping[current -1]
            let current = current - 1
        endwhile
    endif
    let s:tabspaceMapping[tabpagenr()] = t:tabspaceKey
endfunction

function! OpenTabspaceByName(name)
    if has_key(g:tabspaceData, a:name)
        let tab = FindTabIndexForTabspace(a:name)
        exe 'tabnext ' . tab
    else
        if has_key(g:named_tabspaces, a:name)
            tabnew
            call CreateTabspace(g:named_tabspaces[a:name], a:name)
        else
            echoerr "No tabspace with given name found"
        endif
    endif
endfunction

function! CreateTabspaces(tabspaceList, use_current)

    let used_current = !a:use_current
    for tabspaceName in a:tabspaceList
        if used_current == 0
            let used_current = 1
        else
            tabnew
        endif
        call CreateTabspace(g:named_tabspaces[tabspaceName], tabspaceName)
    endfor

endfunction

function! CreateTabspace(tabspace, name)
    let t:tabspaceKey = a:name
    let cwd = has_key(a:tabspace, 'cwd') ? a:tabspace['cwd'] : getcwd()
    let label = has_key(a:tabspace, 'label') ? a:tabspace['label'] : ''
    let activeColor = has_key(a:tabspace, 'activeColor') ? a:tabspace['activeColor'] : ''
    let inactiveColor = has_key(a:tabspace, 'inactiveColor') ? a:tabspace['inactiveColor'] : ''
    let g:tabspaceData[t:tabspaceKey] = {
        \ 'cwd' : cwd,
        \ 'label': label,
        \ 'activeColor': activeColor,
        \ 'inactiveColor': inactiveColor,
        \ 'buffers' : []
    \}
    let s:tabspaceMapping[tabpagenr()] = t:tabspaceKey
    " Since the tab has already been created TabEnter wasn't called
    exe "cd " . cwd
endfunction

function! SetTabspaceColor(...)
    if (a:0 < 1 || a:0 > 2)
        echoe "Function takes 1 or 2 arguments"
    endif
    if (exists("a:1"))
        let color = ConvertColorToHighlight(a:1)
        if !empty(color)
            let g:tabspaceData[t:tabspaceKey]['activeColor'] = color
            let g:tabspaceData[t:tabspaceKey]['inactiveColor'] = color
        else
            echom "Invalid color " . a:1 . ' "' . color . '"'
        endif
    endif
    if (exists("a:2"))
        let color = ConvertColorToHighlight(a:2)
        if !empty(color)
            let g:tabspaceData[t:tabspaceKey]['activeColor'] = color
        else
            echom "Invalid color " . a:2
        endif
    endif
    call RefreshTabspaces()
endfunction

function ConvertColorToHighlight(color)
    if index(['red', 'darkred', 'blue', 'darkblue', 'green', 'darkgreen', 'yellow', 'cyan', 'magenta', 'white', 'black'], tolower(a:color)) >= 0
        return 'Tabspace' . toupper(strpart(a:color, 0, 1)) . tolower(strpart(a:color, 1))
    endif
    return ''
endfunction

" This function cleans up the data held by a tab along with closing the tab
" itself.  Use this instead of tabclose to ensure tabspace keeps information
" up to date
function! TabspaceDelete()
    let current = tabpagenr()
    let tabspaceKey = s:tabspaceMapping[current]
    while current < len(keys(s:tabspaceMapping))
        let s:tabspaceMapping[current] = s:tabspaceMapping[current +1]
        let current = current + 1
    endwhile
    unlet s:tabspaceMapping[current]
    unlet g:tabspaceData[tabspaceKey]

    tabclose
endfunction

function! OpenTabspaceByLabel(label)
    let tab = FindTabspaceByLabel(a:label)
    if tab != ''
        exe 'tabnext ' . tab
    endif
endfunction

function! FindTabspaceByLabel(label)
    for key in keys(g:tabspaceData)
        let tabspace = g:tabspaceData[key]
        if tabspace['label'] == a:label
            return FindTabIndexForTabspace(key)
        endif
    endfor
    return ''
endfunction

function! FindTabIndexForTabspace(tabspaceKey)
    for mappingKey in keys(s:tabspaceMapping)
        if s:tabspaceMapping[mappingKey] == a:tabspaceKey
            return mappingKey
        endif
    endfor
    return ''
endfunction

if g:add_tabspace_nerdtree_mappings

    function! TabspaceNerdTreeCWD()
        let current_file = g:NERDTreeFileNode.GetSelected()

        if current_file == {}
            return
        else
            exe ':TabspaceCWD ' . current_file.path.str()
            silent execute 'normal C'
            silent execute 'normal cd'
        endif

    endfunction

    nnoremap tg :call TabspaceNerdTreeCWD()<CR>
endif

" This is where the magic happens
au TabEnter * :call TabspaceEnter()
au BufAdd * :call TabspaceBufAdd(expand('<abuf>'))
au BufEnter * :call TabspaceBufAdd(expand('<abuf>'))
au BufDelete * :call TabspaceBufDelete(expand('<abuf>'))

"Commands
command! -nargs=1 TabspaceLabel call SetTabspaceLabel(<f-args>)
command! -nargs=1 TabspaceCWD call TabspaceCWD(<f-args>)
command! -nargs=1 OpenTabspaceByLabel call OpenTabspaceByLabel(<f-args>)
command! -nargs=1 OpenTabspaceByName call OpenTabspaceByName(<f-args>)
command! -nargs=* TabspaceColor call SetTabspaceColor(<f-args>)

"Shortcuts
if g:add_tabspace_mappings
    nnoremap <Leader>tj  :tabnext<CR>
    nnoremap <Leader>tk  :tabprev<CR>
    nnoremap <Leader>tt  :tabnew<CR>
    nnoremap <Leader>td  :call TabspaceDelete()<CR>
    nnoremap <Leader>tr  :TabspaceLabel<Space>
    nnoremap <Leader>tm  :OpenTabspaceByLabel<Space>
    nnoremap <Leader>tg  :OpenTabspaceByName<Space>
endif

if exists("g:initial_tabspaces")
    call CreateTabspaces(g:initial_tabspaces, 1)
endif

"Setup for the first tab
call InitializeTabspace()
call RefreshTabspaces()

hi TabspaceRed       guifg=White  guibg=red         ctermfg=White  ctermbg=red       cterm=NONE   gui=NONE
hi TabspaceDarkred   guifg=White  guibg=darkred     ctermfg=White  ctermbg=darkred   cterm=NONE   gui=NONE
hi TabspaceBlue      guifg=White  guibg=blue        ctermfg=White  ctermbg=blue      cterm=NONE   gui=NONE
hi TabspaceDarkblue  guifg=White  guibg=darkblue    ctermfg=White  ctermbg=darkblue  cterm=NONE   gui=NONE
hi TabspaceGreen     guifg=White  guibg=green       ctermfg=White  ctermbg=green     cterm=NONE   gui=NONE
hi TabspaceDarkgreen guifg=White  guibg=darkgreen   ctermfg=White  ctermbg=darkgreen cterm=NONE   gui=NONE
hi TabspaceYellow    guifg=White  guibg=yellow      ctermfg=White  ctermbg=yellow    cterm=NONE   gui=NONE
hi TabspaceCyan      guifg=White  guibg=cyan        ctermfg=White  ctermbg=cyan      cterm=NONE   gui=NONE
hi TabspaceMagenta   guifg=White  guibg=magenta     ctermfg=White  ctermbg=magenta   cterm=NONE   gui=NONE
hi TabspaceBlack     guifg=White  guibg=black       ctermfg=White  ctermbg=black     cterm=NONE   gui=NONE
hi TabspaceGray      guifg=White  guibg=gray        ctermfg=White  ctermbg=gray      cterm=NONE   gui=NONE
hi TabspaceDarkgray  guifg=Black  guibg=darkgray    ctermfg=Black  ctermbg=darkgray  cterm=NONE   gui=NONE
hi TabspaceLightgray guifg=Black  guibg=lightgray   ctermfg=Black  ctermbg=lightgray cterm=NONE   gui=NONE
hi TabspaceWhite     guifg=Black  guibg=white       ctermfg=Black  ctermbg=white     cterm=NONE   gui=NONE
