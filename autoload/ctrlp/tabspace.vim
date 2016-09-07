" =============================================================================
" File:          autoload/ctrlp/tabspace.vim
" Description:   Example extension for ctrlp.vim
" =============================================================================

" To load this extension into ctrlp, add this to your vimrc:
"
"     let g:ctrlp_extensions = ['tabspace']
"
" Where 'tabspace' is the name of the file 'tabspace.vim'
"
" For multiple extensions:
"
"     let g:ctrlp_extensions = [
"         \ 'my_extension',
"         \ 'my_other_extension',
"         \ ]

" Load guard
if ( exists('g:loaded_ctrlp_tabspace') && g:loaded_ctrlp_tabspace )
    \ || v:version < 700 || &cp
    finish
endif
let g:loaded_ctrlp_tabspace = 1


" Add this extension's settings to g:ctrlp_ext_vars
"
" Required:
"
" + init: the name of the input function including the brackets and any
"         arguments
"
" + accept: the name of the action function (only the name)
"
" + lname & sname: the long and short names to use for the statusline
"
" + type: the matching type
"   - line : match full line
"   - path : match full line like a file or a directory path
"   - tabs : match until first tab character
"   - tabe : match until last tab character
"
" Optional:
"
" + enter: the name of the function to be called before starting ctrlp
"
" + exit: the name of the function to be called after closing ctrlp
"
" + opts: the name of the option handling function called when initialize
"
" + sort: disable sorting (enabled by default when omitted)
"
" + specinput: enable special inputs '..' and '@cd' (disabled by default)
"
call add(g:ctrlp_ext_vars, {
    \ 'init': 'ctrlp#tabspace#init()',
    \ 'accept': 'ctrlp#tabspace#accept',
    \ 'lname': 'Tab buffers',
    \ 'sname': 'tabbufs',
    \ 'type': 'line',
    \ 'enter': 'ctrlp#tabspace#enter()',
    \ 'exit': 'ctrlp#tabspace#exit()',
    \ 'opts': 'ctrlp#tabspace#opts()',
    \ 'sort': 0,
    \ 'specinput': 0,
    \ })


" Provide a list of strings to search in
"
" Return: a Vim's List
"
function! ctrlp#tabspace#init()

    let buflist = reverse(copy(g:tabspaceData[t:tabspaceKey]['buffers']))
    let bufferList = []
    for buf in buflist
        let bufname = bufname(buf + 0) " + 0 forces buf to be a number...vimscript
        let addBuffer = 1
        if bufname == ''
            let addBuffer = 0
        else
            for str in g:tabspace_excluded_buffer_names
                if bufname =~ str
                    let addBuffer = 0
                endif
            endfor
        endif
        if addBuffer
            call add(bufferList, bufname)
        endif
    endfor
    return bufferList
endfunction

function TabspaceGetBufferNumber(name)
    let buflist = g:tabspaceData[t:tabspaceKey]['buffers']
    let bufferList = []
    for buf in buflist
        let bufname = bufname(buf + 0) " + 0 forces buf to be a number...vimscript
        if bufname == a:name
            return buf
        endif
    endfor
    return -1
endfunction

" The action to perform on the selected string
"
" Arguments:
"  a:mode   the mode that has been chosen by pressing <cr> <c-v> <c-t> or <c-x>
"           the values are 'e', 'v', 't' and 'h', respectively
"  a:str    the selected string
"
function! ctrlp#tabspace#accept(mode, str)
    if (a:mode == 'e')
        call ctrlp#exit()
        exe ":e " . a:str
        return
    endif
    if (a:mode == 'h')
        call ctrlp#exit()

        let bufferNumber = TabspaceGetBufferNumber(a:str)

        let currentBufferNumber = bufnr("$")
        if currentBufferNumber == bufferNumber
            let buffers = g:tabspaceData[t:tabspaceKey]['buffers']
            for buf in buffers
                if buf != bufferNumber
                    exe ":buffer " . buf
                    break
                endif
            endfor
        endif
        call TabspaceBufDelete(bufferNumber)
        return
    endif
endfunction


" (optional) Do something before enterting ctrlp
function! ctrlp#tabspace#enter()
endfunction


" (optional) Do something after exiting ctrlp
function! ctrlp#tabspace#exit()
endfunction


" (optional) Set or check for user options specific to this extension
function! ctrlp#tabspace#opts()
endfunction

" Give the extension an ID
let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)
" Allow it to be called later
function! ctrlp#tabspace#id()
  return s:id
endfunction
