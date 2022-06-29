if exists('*nvim_create_namespace')
    let s:namespace = nvim_create_namespace('')
else
    echoerr 'virtual highlighting only works with Neovim v0.3.2 - please upgrade'
    finish
endif

fun! virtual#highlight(bufnr) abort
    for it in getbufvar(a:bufnr, 'human_dates', [])

        let chunks = [[it.date, "Comment"]]
        if exists('*nvim_buf_get_virtual_text')
            let chunks += nvim_buf_get_virtual_text(a:bufnr, it.lnum - 1)
        elseif exists('*nvim_buf_get_extmarks')
            let set_chunks = nvim_buf_get_extmarks(
                    \   a:bufnr,
                    \   s:namespace,
                    \   [it.lnum - 1, 0],
                    \   [it.lnum - 1, 0],
                    \   {'details': v:true}
                    \ )
            if !empty(set_chunks)
                let chunks += set_chunks[0][3].virt_text
            endif
        endif
        call nvim_buf_set_virtual_text(
                    \   a:bufnr,
                    \   s:namespace,
                    \   it.lnum - 1,
                    \   chunks,
                    \   {}
                    \ )
    endfor
endf

fun! virtual#tearDown(bufnr) abort
    if !bufexists(a:bufnr)
        return
    endif

    if exists('*nvim_buf_clear_namespace')
        call nvim_buf_clear_namespace(a:bufnr, s:namespace, 0, -1)
    endif
endf
