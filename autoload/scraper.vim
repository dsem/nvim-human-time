" Used for Vim because it has a shit api
let s:chan_infos = {}

fun! scraper#toggle() abort
    let b:humantime_is_on = get(b:, 'humantime_is_on', 0)
    if b:humantime_is_on
        call scraper#off()
    else
        call scraper#on()
    endif
endf

fun! scraper#on() abort
    call s:cancel_cur_job()

    let b:humantime_is_on = 1
    let b:humantime_is_disabled = 0
    let tmpname = utils#tmpname()
    let fail = writefile(getbufline(bufnr('%'), 1, '$'), tmpname)
    if fail
        let b:humantime_is_on = 0
    else
        if has('nvim')
            let opts = {
                        \ 'tmpname': tmpname,
                        \ 'on_stdout': function('s:on_stdout'),
                        \ 'on_stderr': function('s:on_stderr'),
                        \ 'on_exit': function('s:on_exit'),
                        \ 'bufnr': bufnr('%'),
                        \ 'dates': []
                        \ }
        else
            let opts = {
                        \ 'out_cb': function('s:on_stdout_vim'),
                        \ 'close_cb': function('s:on_exit_vim'),
                        \ }
        endif
        if has('macunix')
            let date_cmd = 'date -r '
        else
            let date_cmd = 'date -d @'
        endif
        let cmd = "grep -Eon '\\b[0-9]{10}\\b' ".tmpname." | sed -r 's#([0-9]+):(\\b[0-9]{10}\\b)#printf \"%s\" \"\\1|\" \"$(".date_cmd."\\2)\"# | sh'"

        if has('nvim')
            let b:humantime_job_id = jobstart(cmd, opts)
        else
            let b:humantime_job = job_start(cmd, opts)
            let s:chan_infos[ch_info(job_getchannel(b:humantime_job)).id] = {
                        \     'tmpname': tmpname,
                        \     'bufnr': bufnr('%'),
                        \     'dates': []
                        \ }
        endif
    endif
endf

fun! scraper#off() abort
    let b:humantime_is_on = 0
    let b:humantime_is_disabled = 1
    call s:cancel_cur_job()
    call s:clear_hl(bufnr('%'))
endf

fun! s:clear_hl(bufnr) abort
    for F in g:HumanTime_tearDownCallbacks
        call F(a:bufnr)
    endfor
endf

fun! s:cancel_cur_job() abort
    try
        if has('nvim')
            let b:humantime_job_id = get(b:, 'humantime_job_id', -1)
            call chanclose(b:humantime_job_id)
        else
            if has_key(b:, 'humantime_job')
                call ch_close(b:humantime_job)
            endif
        endif
    catch /E90[06]/
    endtry
endf

fun! s:on_stdout_vim(chan, line) abort
    let date = s:parse_date(a:line)
    if !empty(date)
        call add(s:chan_infos[ch_info(a:chan).id].date, date)
    endif
endf

fun! s:on_exit_vim(chan) abort
    let info = s:chan_infos[ch_info(a:chan).id]
    call delete(info.tmpname)
    call s:clear_hl(info.bufnr)
    call setbufvar(info.bufnr, 'human_dates', info.dates)
    for F in g:HumanTime_highlightCallbacks
        call F(info.bufnr)
    endfor
endf

fun! s:on_stdout(id, data, event) abort dict
    for line in a:data
        let date = s:parse_date(line)
        if !empty(date)
            call add(self.dates, date)
        endif
    endfor
endf

fun! s:on_stderr(id, data, event) abort dict
    if get(g:, 'HumanTime_logging', 0)
        echohl Error | echom string(a:data) | echohl None
    endif
endf

fun! s:on_exit(id, status, event) abort dict
    call delete(self.tmpname)
    call s:clear_hl(self.bufnr)
    if a:status
        return
    endif
    call setbufvar(self.bufnr, 'human_dates', self.dates)
    for F in g:HumanTime_highlightCallbacks
        call F(self.bufnr)
    endfor
endf

fun! s:parse_date(line) abort
    let parts = split(a:line, '|')
    if len(parts) < 2
        return ''
    endif
    return { 'lnum': parts[0], 'date': parts[1] }
endf
