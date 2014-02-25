" Vim syntax file
" Language:         Vic
" Maintainter:      Vikas N Kumar <vikas@cpan.org>
" URL:              http://github.com/vikasnkumar/vic
" Last Change:      2014-01-30
" Contributors:     Vikas N Kumar <vikas@cpan.org>
"
"
if exists("b:current_syntax")
  finish
endif

syn keyword vicHeader       config array table contained
syn keyword vicStatement    delay hang analog_input digital_input digital_output
syn keyword vicStatement    adc_enable adc_disable adc_read delay_ms delay_us delay_s
syn keyword vicStatement    debounce digital_output write read ror rol timer_enable
syn keyword vicStatement    timer
syn keyword vicBlock        Main Loop Action True False ISR
syn keyword vicPICStatement PIC contained
syn region  vicString1      start=+'+  end=+'\|$+
syn region  vicString2      start=+"+  end=+"\|$+
syn match   vicNumberUnits  "\<\%([0-9][[:digit:]]*\)\%(s\|ms\|us\|MHz\|kHz\|Hz\)\>"
syn match   vicNumber       "\<\%(0\%(x\x[[:xdigit:]_]*\|b[01][01_]*\|\o[0-7_]*\|\)\|[1-9][[:digit:]_]*\)\>"
syn match   vicComment      "#.*"
syn match   vicPIC          "\<PIC\s\+\%(\w\)*" contains=vicPICStatement
syn match   vicVariable     "\$\w*"
syn match   vicConfig       "\<config\s\+\%(\w\)*\s\+\%(\w\)*" contains=vicHeader
syn match   vicValidVars    "\<\%(\%(PORT\|TRIS\)\w\w*\)\|\%([RA][A-Z][0-9]\)\>"
syn match   vicValidVars    "\<\%(\w\+CON[0-9]*\)\|\%(TMR[0-9]*\)\|\%(ANSEL\w*\)\>"
syn match   vicValidVars    "\<\%(ADRES\w*\)\|\%(\w\+REG\w?\)\|\%(PCL\w*\)\>"
syn match   vicValidVars    "\<\%(FSR\|STATUS\|OPTION_REG\|IND\)\w*\>"

highlight link vicStatement     Statement 
highlight link vicHeader        PreProc
highlight link vicBlock         Function
highlight link vicString1       String
highlight link vicString2       String
highlight link vicNumber        Number
highlight link vicNumberUnits   Number
highlight link vicComment       Comment
highlight link vicPIC           Type
highlight link vicPICStatement  Special
highlight link vicVariable      Identifier
highlight link vicConfig        PreProc
highlight link vicValidVars     Type

let b:current_syntax = "vic"

" vim: ts=8
