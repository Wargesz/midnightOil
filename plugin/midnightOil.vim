" Title:        midnightOil
" Description:  Self hosted wakatime clone text editor plugin
" Last Change:   
" Maintainer:   Wargesz <https://github.com/Wargesz>

" Prevents the plugin from being loaded multiple times. If the loaded
" variable exists, do nothing more. Otherwise, assign the loaded
" variable and continue running this instance of the plugin.
if exists("g:loaded_midnightOil")
    finish
endif
let g:loaded_midnightOil = 1

" Exposes the plugin's functions for use as commands in Vim.
command! -nargs=0 SayHi call midnightOil#SayHi()

