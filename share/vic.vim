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
syn keyword vicStatement    port_value output_port delay hang input_port analog_input_port
syn keyword vicStatement    adc_init adc_disable adc_read digital_input_port
syn keyword vicStatement    debounce
syn keyword vicBlock        Main Loop Action
syn keyword vicPICStatement PIC contained
syn region  vicString1      start=+'+  end=+'\|$+
syn region  vicString2      start=+"+  end=+"\|$+
syn match   vicNumberUnits  "\<\%([0-9][[:digit:]]*\)\%(s\|ms\|us\|MHz\|kHz\|Hz\)\>"
syn match   vicNumber       "\<\%(0\%(x\x[[:xdigit:]_]*\|b[01][01_]*\|\o[0-7_]*\|\)\|[1-9][[:digit:]_]*\)\>"
syn match   vicComment      "#.*"
syn match   vicPIC          "\<PIC\s\+\%(\w\)*" contains=vicPICStatement
syn match   vicVariable     "\$\w*"
syn match   vicConfig       "\<config\s\+\%(\w\)*\s\+\%(\w\)*" contains=vicHeader

highlight link vicStatement     Statement 
highlight link vicHeader        Type
highlight link vicBlock         Function
highlight link vicString1       String
highlight link vicString2       String
highlight link vicNumber        Number
highlight link vicNumberUnits   Number
highlight link vicComment       Comment
highlight link vicPIC           Type
highlight link vicPICStatement  Special
highlight link vicVariable      Identifier
highlight link vicConfig        Function

let b:current_syntax = "vic"

" vim: ts=8
