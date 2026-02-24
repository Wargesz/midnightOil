function! midnightOil#LoadConfig(...)
    if !executable('curl')
        let s:dict['errormsg'] = 'curl not found'
        return
    endif
    try
        let home = expand("$HOME")
        if getfperm(home . '/.midnightOil.config') != 'rw-------'
            let s:dict['errormsg'] = 'open config file. 600 needed.'
            return
        endif
        let lines = readfile(home . '/.midnightOil.config')
        for line in lines
            let v = split(line,'=')
            let s:dict[tolower(v[0])] = v[1]
        endfor
        if !exists("s:dict['api-key']") || !exists("s:dict['address']")
            let s:dict['errormsg'] = "configError"
        else
            let s:dict['ready'] = 1
        endif
    catch /Can't open/
        let s:dict['errormsg'] = "readError"
    endtry
endfunction

function! midnightOil#StartMidnight(...)
    let t:startTime = midnightOil#GetDate()
    let s:secondsPassed = 0
    let s:dict = {'ready':0, 'errormsg':''}
    call midnightOil#LoadConfig()
    call midnightOil#StartTimer()
    call timer_pause(s:dict['timer'], 1)
endfunction

function! midnightOil#StopMidnight(...)
    if s:dict['errormsg'] != ''
        return
    endif
    if s:secondsPassed == 0
        return
    endif
    if &modified
        return
    endif
    let t:endTime = midnightOil#GetDate()
    call midnightOil#Calculate()
    let s:secondsPassed = 0
endfunction

function! midnightOil#Calculate(...)
    let file = expand("%:p")
    if expand("%") == ""
        return
    endif
    let args = 'curl -Ld start=' . string(t:startTime) .
                \'\&end=' . string(t:endTime) .
                \'\&seconds=' . string(s:secondsPassed) .
                \'\&file=' . string(file) .
                \'\&api-key=' . s:dict['api-key']  .
                \'\&editor=vim ' . s:dict['address'] .
                \'/mno'
    call system(args)
endfunction

function! midnightOil#GetDate(...)
    return strftime("%Y-%b-%d_%H:%M:%S")
endfunction

function! midnightOil#IncrementSeconds(...)
    let s:secondsPassed += 1
    call lightline#update()
endfunction

function! midnightOil#StartTimer(...)
    let s:dict['timer'] = timer_start(1000,'midnightOil#IncrementSeconds', { 'repeat': -1 } )
endfunction

function! midnightOil#StatusBar(...)
    if s:dict['ready']
        return midnightOil#LeadingZero(s:secondsPassed/60) . string(s:secondsPassed/60) . ":" . midnightOil#LeadingZero(s:secondsPassed%60) . string(s:secondsPassed%60)
    else
        return s:dict['errormsg']
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
        call timer_pause(s:dict['timer'], 1)
    else
	call timer_pause(s:dict['timer'], 0)
    endif
endfunction
