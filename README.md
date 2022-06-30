# nvim-human-time

Display unix timestamps in human-readable form

![screenshot](screenshot.png)

## About

The plugin leverages unix commands such as `sed`, `grep`, and `date` to
identify and convert unix timestamps into a human-readable format.

There are no customization options.

**Full disclosure: I don't actually know what I'm doing.**  This codebase is
borrowed almost entirely from
[vim-hexokinase](https://github.com/RRethy/vim-hexokinase) with lots of lines
removed and a few lines changed.

Here are some things I don't know:

 - **Can this work for vanilla vim?** I'm not sure vim has a concept of virtual
   text.
 - **The plugin writes a temporary file, then runs `grep`, `sed`, and `date` on
   the entire the file to parse and convert timestamps. Wouldn't it be better
   to do that line-by-line within the buffer?** Probably.
 - **Shouldn't we be able to do this with vim's internal `strftime()`?** Probably.
 - **Shouldn't we be able to add customization of the time format?** Probably.


## Requirements

- Neovim 0.3.2 or greater

This has been tested with bash on Linux and MacOS.

## Installation

```vim
" vim-plug
Plug 'dsem/nvim-human-time'

" minpac
call minpac#add('dsem/nvim-human-time')

" dein
call dein#add('dsem/nvim-human-time')

" etc.
```

## Commands

| Command  | Description  |
|---|---|
| **HumanTimeToggle**  | Toggle the date conversions  |
| **HumanTimeTurnOn**  | Turn on date conversions (refresh if already turned on) |
| **HumanTimeTurnOff**  | Turn off the date conversions|

## Full Configuration

See `:help human-time.txt`

## Thanks

Thank you to RRethy for producing `vim-hexokinase`, a very useful plugin
which was used as the basis for this work.
