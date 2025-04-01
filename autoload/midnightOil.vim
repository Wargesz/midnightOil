function! midnightOil#LoadConfig(...)
				try
										let home = expand("$HOME")
										let lines = readfile(home . '/.midnightOil.config')
										for line in lines
														let v = split(line,'=')
														let g:dict[tolower(v[0])] = v[1]
										endfor
										if !exists("g:dict['api-key']") || !exists("g:dict['address']")
														let g:dict['errormsg'] = "configError"
														call timer_stop(g:dict['timer'])
										else
														let g:dict['ready'] = 1
										endif
				catch /Can't open/
								let g:dict['errormsg'] = "readError"
								call timer_stop(g:dict['timer'])
				endtry
endfunction

function! midnightOil#StartMidnight(...)
				let t:startTime = midnightOil#GetDate()
				let g:secondsPassed = 0
				let g:dict = {'ready':0, 'errormsg':''}
				call midnightOil#StartTimer()
				call midnightOil#LoadConfig()
endfunction

function! midnightOil#StopMidnight(...)
				let t:endTime = midnightOil#GetDate()
				call midnightOil#Calculate()
endfunction

function! midnightOil#Calculate(...)
				if g:dict['errormsg'] != ''
								return
				endif
				let t:projectName = getcwd()
				let t:arg = "curl -d \'start=" . string(t:startTime) . 
																\"&end=" . string(t:endTime) . 
																\"&seconds=" . string(g:secondsPassed) .
																\"&project=" . string(t:projectName) . 
																\"&api-key=" . g:dict['api-key']  . 
																\"&editor=vim\' " . g:dict['address'] . 
																\"/midnightOil"
				call system(t:arg)
endfunction

function! midnightOil#GetDate(...)
				return strftime("%b-%d_%H:%M:%S")
endfunction

function! midnightOil#IncrementSeconds(...)
				let g:secondsPassed += 1
			 	call lightline#update()
endfunction

function! midnightOil#StartTimer(...)
				let g:dict['timer'] = timer_start(1000,'midnightOil#IncrementSeconds', { 'repeat': -1 } )
endfunction

function! midnightOil#StatusBar(...)
				if g:dict['ready']
								return midnightOil#LeadingZero(g:secondsPassed/60) . string(g:secondsPassed/60) . ":" . midnightOil#LeadingZero(g:secondsPassed%60) . string(g:secondsPassed%60)
				else
								return g:dict['errormsg']
				endif
endfunction

function! midnightOil#LeadingZero(value)
				if a:value < 10
								return "0"
				else
								return ""
				endif
endfunction
