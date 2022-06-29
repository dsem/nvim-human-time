" nvim-human-time - Display unix timestamps in human-readable form
" Maintainer: Dylan Semler (dsem) <dylan.semler@gmail.com>
" Version 1.0

if exists('g:loaded_humantime')
    finish
endif

let g:loaded_humantime = 1

call main#setup()
