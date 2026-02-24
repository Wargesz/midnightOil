function! midnightOil#LoadConfig(...)
    if !executable('curl')
        let b:dict['errormsg'] = 'curl not found'
        return
    endif
    try
        let home = expand("$HOME")
        if getfperm(home . '/.midnightOil.config') != 'rw-------'
            let b:dict['errormsg'] = 'open config file. 600 needed.'
            return
        endif
        let lines = readfile(home . '/.midnightOil.config')
        for line in lines
            let v = split(line,'=')
            let b:dict[tolower(v[0])] = v[1]
        endfor
        if !exists("b:dict['api-key']") || !exists("b:dict['address']")
            let b:dict['errormsg'] = "configError"
        else
            let b:dict['ready'] = 1
        endif
    catch /Can't open/
        let b:dict['errormsg'] = "readError"
    endtry
endfunction

function! midnightOil#StartMidnight(...)
    let b:startTime = midnightOil#GetDate()
    let b:secondsPassed = 0
    let b:dict = {'ready':0, 'errormsg':''}
    call midnightOil#LoadConfig()
    call midnightOil#StartTimer()
    call timer_pause(b:dict['timer'], 1)
endfunction

function! midnightOil#StopMidnight(...)
    if b:dict['errormsg'] != ''
        return
    endif
    if b:secondsPassed == 0
        return
    endif
    if &modified
        return
    endif
    let b:endTime = midnightOil#GetDate()
    call midnightOil#Calculate()
    let b:secondsPassed = 0
endfunction

function! midnightOil#Calculate(...)
    let file = expand("%:p")
    if expand("%") == ""
        return
    endif
    let args = 'curl -Ld start=' . string(b:startTime) .
                \'\&end=' . string(b:endTime) .
                \'\&seconds=' . string(b:secondsPassed) .
                \'\&file=' . string(file) .
                \'\&api-key=' . b:dict['api-key']  .
                \'\&editor=vim ' . b:dict['address'] .
                \'/mno'
    call system(args)
endfunction

function! midnightOil#GetDate(...)
    return strftime("%Y-%b-%d_%H:%M:%S")
endfunction

function! midnightOil#IncrementSeconds(...)
    let b:secondsPassed += 1
    call lightline#update()
endfunction

function! midnightOil#StartTimer(...)
    let b:dict['timer'] = timer_start(1000,'midnightOil#IncrementSeconds', { 'repeat': -1 } )
endfunction

function! midnightOil#StatusBar(...)
    if b:dict['ready']
        return midnightOil#LeadingZero(b:secondsPassed/60) . string(b:secondsPassed/60) . ":" . midnightOil#LeadingZero(b:secondsPassed%60) . string(b:secondsPassed%60)
    else
        return b:dict['errormsg']
    endif
endfunction

function! midnightOil#LeadingZero(value)
    if a:value < 10
        return "0"
    else
        return ""
    endif
endfunction

function! midnightOil#ToggleStatus()
    if mode() == 'n' || mode() == 'c'
        call timer_pause(b:dict['timer'], 1)
    else
	call timer_pause(b:dict['timer'], 0)
    endif
endfunction
