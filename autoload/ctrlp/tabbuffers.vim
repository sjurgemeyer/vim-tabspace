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
if ( exists('g:loaded_ctrlp_tabbuffers') && g:loaded_ctrlp_tabbuffers )
    \ || v:version < 700 || &cp
    finish
endif
let g:loaded_ctrlp_tabbuffers = 1


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
    \ 'init': 'ctrlp#tabbuffers#init()',
    \ 'accept': 'ctrlp#tabbuffers#accept',
    \ 'lname': 'Tab buffers',
    \ 'sname': 'tabbufs',
    \ 'type': 'line',
    \ 'enter': 'ctrlp#tabbuffers#enter()',
    \ 'exit': 'ctrlp#tabbuffers#exit()',
    \ 'opts': 'ctrlp#tabbuffers#opts()',
    \ 'sort': 0,
    \ 'specinput': 0,
    \ })


" Provide a list of strings to search in
"
" Return: a Vim's List
"
function! ctrlp#tabbuffers#init()

    let buflist = reverse(copy(g:tabspaceData[t:tabspaceKey]['buffers']))
    let bufferList = []
    for buf in buflist
        let bufname = bufname(buf + 0) " + 0 forces buf to be a number...vimscript
        let addBuffer = 1
        for str in g:tabspace_excluded_buffer_names
            if bufname =~ str
                let addBuffer = 0
            endif
        endfor

        if addBuffer
            if (bufname == '')
                let bufname = "<No Name>" . buf
            endif
            call add(bufferList, bufname)
        endif
    endfor
    return bufferList
endfunction

" The action to perform on the selected string
"
" Arguments:
"  a:mode   the mode that has been chosen by pressing <cr> <c-v> <c-t> or <c-x>
"           the values are 'e', 'v', 't' and 'h', respectively
"  a:str    the selected string
"
function! ctrlp#tabbuffers#accept(mode, str)
    if (a:mode == 'e')
        call ctrlp#exit()
        if a:str =~ "\<No Name\>"
            exe ":buffer " . strpart(a:str, 9)
        else
            exe ":e " . a:str
        endif
        return
    endif
    if (a:mode == 'h')
        "call ctrlp#exit()

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

        call ctrlp#setlines() " Refresh list
        return
    endif
endfunction

function! TabspaceGetBufferNumber(name)
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

" (optional) Do something before enterting ctrlp
function! ctrlp#tabbuffers#enter()
endfunction


" (optional) Do something after exiting ctrlp
function! ctrlp#tabbuffers#exit()
endfunction


" (optional) Set or check for user options specific to this extension
function! ctrlp#tabbuffers#opts()
endfunction

" Give the extension an ID
let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)
" Allow it to be called later
function! ctrlp#tabbuffers#id()
  return s:id
endfunction
