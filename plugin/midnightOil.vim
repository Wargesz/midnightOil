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
"command! -nargs=0 StartMidnight call midnightOil#StartMidnight()
"command! -nargs=0 StopMidnight call midnightOil#StopMidnight()
"command! -nargs=0 Calculate call midnightOil#Calculate()
"command! -nargs=0 LoadConfig call midnightOil#LoadConfig()
"command! -nargs=0 StartTimer call midnightOil#StartTimer()
"command! -nargs=0 IncrementSeconds call midnightOil#IncrementSeconds()
"command! -nargs=0 MidnightOilStatusBar call midnightOil#StatusBar()

au VimEnter * call midnightOil#StartMidnight()
au VimLeave * call midnightOil#StopMidnight()
