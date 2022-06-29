scriptencoding utf-8

fun! main#setup() abort
    let g:HumanTime_highlightCallbacks = get(g:, 'HumanTime_highlightCallbacks', [])
    let g:HumanTime_tearDownCallbacks = get(g:, 'HumanTime_tearDownCallbacks', [])

    call add(g:HumanTime_highlightCallbacks, function('virtual#highlight'))
    call add(g:HumanTime_tearDownCallbacks, function('virtual#tearDown'))

    command! HumanTimeToggle call scraper#toggle()
    command! HumanTimeTurnOn call scraper#on()
    command! HumanTimeTurnOff call scraper#off()

    let g:HumanTime_refreshEvents = get(g:, 'HumanTime_refreshEvents', ['TextChanged', 'InsertLeave', 'BufRead'])
    let g:HumanTime_ftDisabled = get(g:, 'HumanTime_ftDisabled', [])
    let g:HumanTime_termDisabled = get(g:, 'HumanTime_termDisabled', 0)

    augroup humantime_autocmds
        autocmd!
        exe 'autocmd '.join(g:HumanTime_refreshEvents, ',').' * call s:on_refresh_event()'
        autocmd ColorScheme * call s:on_refresh_event()
    augroup END
endf

fun! s:on_refresh_event() abort
    let b:humantime_is_on = get(b:, 'humantime_is_on', 0)
    let b:humantime_is_disabled = get(b:, 'humantime_is_disabled', 0)
    if b:humantime_is_on
        call scraper#on()
        return
    endif

    if b:humantime_is_disabled
        return
    endif

    if g:HumanTime_termDisabled && &buftype ==# 'terminal'
        return
    endif

    if !empty(g:HumanTime_ftDisabled)
        if index(g:HumanTime_ftDisabled, &filetype) > -1
            return
        endif
    elseif has_key(g:, 'HumanTime_ftEnabled')
        if index(g:HumanTime_ftEnabled, &filetype) == -1
            return
        endif
    endif

    call scraper#on()
endf
