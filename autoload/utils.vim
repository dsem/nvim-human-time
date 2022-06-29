fun! utils#tmpname() abort
    let l:clear_tempdir = 0

    if exists('$TMPDIR') && empty($TMPDIR)
        let l:clear_tempdir = 1
        let $TMPDIR = '/tmp'
    endif

    try
        let l:name = tempname()
    finally
        if l:clear_tempdir
            let $TMPDIR = ''
        endif
    endtry

    return l:name
endf
