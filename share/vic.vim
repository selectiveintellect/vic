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
syn keyword vicStatement    timer shl shr
syn keyword vicBlock        Main Loop Action True False ISR
syn keyword vicModifier     sqrt high low int char hex if while unless
" contained is needed to show that the color highlighting is only valid when
" part of another match
syn keyword vicPICStatement PIC contained
syn region  vicString1      start=+'+  end=+'\|$+
syn region  vicString2      start=+"+  end=+"\|$+
syn match   vicNumberUnits  "\<\%([0-9][[:digit:]]*\)\%(s\|ms\|us\|MHz\|kHz\|Hz\)\>"
syn match   vicNumber       "\<\%(0\%(x\x[[:xdigit:]_]*\|b[01][01_]*\|\o[0-7_]*\|\)\|[1-9][[:digit:]_]*\)\>"
syn keyword vicBoolean      TRUE FALSE true false
syn match   vicComment      "#.*"
syn match   vicPIC          "\<PIC\s\+\%(\w\)*" contains=vicPICStatement
syn match   vicVariable     "\$\w*"
syn match   vicValidVars    "\<\%(\%(PORT\|TRIS\)\w\w*\)\|\%([RA][A-Z][0-9]\)\>"
syn match   vicValidVars    "\<\%(\w\+CON[0-9]*\)\|\%(TMR[0-9HL]*\)\|\%(ANSEL\w*\)\>"
syn match   vicValidVars    "\<\%(ADRES\w*\)\|\%(\w\+REG\w?\)\|\%(PCL\w*\)\>"
syn match   vicValidVars    "\<\%(UART\|USART\|FSR\|STATUS\|OPTION_REG\|IND\)\w*\>"
syn match   vicConfig       "\<config\s\+\$\?\%(\w\)*\s\+\%(\w\)*" contains=vicHeader,vicVariable,vicValidVars

highlight link vicStatement     Statement 
highlight link vicBlock         Function
highlight link vicString1       String
highlight link vicString2       String
highlight link vicNumber        Number
highlight link vicNumberUnits   Number
highlight link vicBoolean       Number
highlight link vicComment       Comment
highlight link vicPIC           Type
highlight link vicPICStatement  Special
highlight link vicConfig        PreProc
highlight link vicVariable      Identifier
highlight link vicHeader        PreProc
highlight link vicValidVars     Type
highlight link vicModifier      Type

let b:current_syntax = "vic"

" vim: ts=8
