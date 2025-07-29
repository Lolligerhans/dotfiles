" Generate header guard based on filename
nnoremap <localleader>ii <cmd>s/.*/\=expand("%")/ \| s/[^[:alpha:]]/_/g \| s/.*/#ifndef \U&_INCLUDED<cr>

" Comment lines that do not already start comment symbol
" TODO: Can we query the comment symbol and use on any file type?
nnoremap <localleader>c :s/^\($\)\@!\(\s*\/\/\)\@!/\/\/<cr>
vnoremap <localleader>c :s/^\($\)\@!\(\s*\/\/\)\@!/\/\/<cr>
nnoremap <localleader>C :s/^\/\///<cr>
vnoremap <localleader>C :s/^\/\///<cr>
