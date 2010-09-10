if exists("s:seen") && !exists("s:debug")
	finish
endif

let s:seen=1
" let s:debug=1
command! -nargs=1 SmtEdit call savemytext#SmtEdit(<f-args>)
command! -nargs=1 SmtWrite call savemytext#SmtWrite(<f-args>)
command! -nargs=1 SmtList call savemytext#SmtList(<f-args>)
command! -nargs=+ SmtDelete call savemytext#SmtDelete(<f-args>)
augroup Smt
	autocmd!
	au BufReadCmd   smt:*,smt:*/* SmtEdit <afile>
	au FileReadCmd  smt:*,smt:*/* SmtEdit <afile>
	au BufWriteCmd  smt:*,smt:*/* SmtWrite <afile>
	au FileWriteCmd smt:*,smt:*/* SmtWrite <afile>
augroup END
