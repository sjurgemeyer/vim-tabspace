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
    let tabspaceKey = s:tabspaceMapping[a:tab]
    let selected = a:tab == tabpagenr()
    if (selected)
        let highlight = s:tabspaceData[tabspaceKey]['activeColor']
        if empty(highlight)
            let highlight = g:tabspace_selected_tab_highlight
        endif
    else
        let highlight = s:tabspaceData[tabspaceKey]['inactiveColor']
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
            \ 'label': '',
            \ 'activeColor' : '',
            \ 'inactiveColor' : ''
        \}
    endif
    let s:tabspaceMapping[tabpagenr()] = t:tabspaceKey " TODO, this will only handle the current tab.  Need to cleanup other tabs
endfunction

function! CreateTabspaces(tabspaceList, use_current)

    let used_current = !a:use_current
    for tabspace in a:tabspaceList
        if used_current == 0
            let used_current = 1
        else
            tabnew
        endif
        let s:tabspaceIndex = s:tabspaceIndex + 1
        let t:tabspaceKey = s:tabspaceIndex
        let cwd = has_key(tabspace, 'cwd') ? tabspace['cwd'] : getcwd()
        let label = has_key(tabspace, 'label') ? tabspace['label'] : ''
        let activeColor = has_key(tabspace, 'activeColor') ? tabspace['activeColor'] : ''
        let inactiveColor = has_key(tabspace, 'inactiveColor') ? tabspace['inactiveColor'] : ''
        let s:tabspaceData[t:tabspaceKey] = {
            \ 'cwd' : cwd,
            \ 'label': label,
            \ 'activeColor': activeColor,
            \ 'inactiveColor': inactiveColor
        \}
        let s:tabspaceMapping[tabpagenr()] = t:tabspaceKey
    endfor
endfunction

function! SetTabspaceColor(...)
    if (a:0 < 1 || a:0 > 2)
        echoe "Function takes 1 or 2 arguments"
    endif
    if (exists("a:1"))
        let color = ConvertColorToHighlight(a:1)
        if !empty(color)
            let s:tabspaceData[t:tabspaceKey]['activeColor'] = color
            let s:tabspaceData[t:tabspaceKey]['inactiveColor'] = color
        else
            echom "Invalid color " . a:1 . ' "' . color . '"'
        endif
    endif
    if (exists("a:2"))
        let color = ConvertColorToHighlight(a:2)
        if !empty(color)
            let s:tabspaceData[t:tabspaceKey]['activeColor'] = color
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
    unlet s:tabspaceData[tabspaceKey]

    tabclose
endfunction

function! TabspaceGo(name)
    for key in keys(s:tabspaceData)
        let tabspace = s:tabspaceData[key]
        if tabspace['label'] == a:name
            for mappingKey in keys(s:tabspaceMapping)
                if s:tabspaceMapping[mappingKey] == key
                    let tab = mappingKey
                endif
            endfor
            echom tab
            exe 'tabnext ' . tab
            return
        endif
    endfor
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

"Commands
command! -nargs=1 TabspaceLabel call SetTabspaceLabel(<f-args>)
command! -nargs=1 TabspaceCWD call TabspaceCWD(<f-args>)
command! -nargs=1 TabspaceGo call TabspaceGo(<f-args>)
command! -nargs=* TabspaceColor call SetTabspaceColor(<f-args>)

"Shortcuts
if g:add_tabspace_mappings
    nnoremap <Leader>tj  :tabnext<CR>
    nnoremap <Leader>tk  :tabprev<CR>
    nnoremap <Leader>tt  :tabnew<CR>
    nnoremap <Leader>td  :call TabspaceDelete()<CR>
    nnoremap <Leader>tr  :TabspaceLabel<Space>
    nnoremap <Leader>tm  :TabspaceGo<Space>
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
