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
if ( exists('g:loaded_ctrlp_namedtabspaces') && g:loaded_ctrlp_namedtabspaces )
    \ || v:version < 700 || &cp
    finish
endif
let g:loaded_ctrlp_namedtabspaces = 1


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
    \ 'init': 'ctrlp#namedtabspaces#init()',
    \ 'accept': 'ctrlp#namedtabspaces#accept',
    \ 'lname': 'Named Tabspaces',
    \ 'sname': 'presets',
    \ 'type': 'line',
    \ 'enter': 'ctrlp#namedtabspaces#enter()',
    \ 'exit': 'ctrlp#namedtabspaces#exit()',
    \ 'opts': 'ctrlp#namedtabspaces#opts()',
    \ 'sort': 0,
    \ 'specinput': 0,
    \ })


" Provide a list of strings to search in
"
" Return: a Vim's List
"
function! ctrlp#namedtabspaces#init()
    return keys(g:named_tabspaces)
endfunction


" The action to perform on the selected string
"
" Arguments:
"  a:mode   the mode that has been chosen by pressing <cr> <c-v> <c-t> or <c-x>
"           the values are 'e', 'v', 't' and 'h', respectively
"  a:str    the selected string
"
function! ctrlp#namedtabspaces#accept(mode, str)
    if (a:mode == 'e')
        call ctrlp#exit()
        exe ":OpenTabspaceByName " . a:str
        return
    endif
endfunction


" (optional) Do something before enterting ctrlp
function! ctrlp#namedtabspaces#enter()
endfunction


" (optional) Do something after exiting ctrlp
function! ctrlp#namedtabspaces#exit()
endfunction


" (optional) Set or check for user options specific to this extension
function! ctrlp#namedtabspaces#opts()
endfunction

" Give the extension an ID
let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)
" Allow it to be called later
function! ctrlp#namedtabspaces#id()
  return s:id
endfunction
