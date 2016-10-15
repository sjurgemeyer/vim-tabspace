
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
