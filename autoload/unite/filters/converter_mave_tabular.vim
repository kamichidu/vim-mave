" The MIT License (MIT)
" 
" Copyright (c) 2014 kamichidu
" 
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
" 
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
" 
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
" THE SOFTWARE.
let s:save_cpo= &cpo
set cpo&vim

let s:V= vital#of('mave')
let s:S= s:V.import('Data.String')
unlet s:V

let s:tabular= {
\   'name': 'converter_mave_tabular',
\   'description': '',
\}

function! s:tabular.filter(candidates, context)
    let l:candidates= deepcopy(a:candidates)
    let l:left_width= 0
    let l:center_width= 0
    let l:right_width= 0

    for l:candidate in l:candidates
        let l:text= get(l:candidate, 'abbr', l:candidate.word)
        let l:parts= split(l:text, '\\\@<!|', 1)

        let l:left_width=   max([l:left_width,   strlen(get(l:parts, 0, ''))])
        let l:center_width= max([l:center_width, strlen(get(l:parts, 1, ''))])
        let l:right_width=  max([l:right_width,  strlen(get(l:parts, 2, ''))])
    endfor

    for l:candidate in l:candidates
        let l:text= get(l:candidate, 'abbr', l:candidate.word)
        let l:parts= split(l:text, '\\\@<!|', 1)

        let l:left=   s:S.pad_right(get(l:parts, 0, ''), l:left_width)
        let l:center= s:S.pad_right(get(l:parts, 1, ''), l:center_width)
        let l:right=  s:S.pad_right(get(l:parts, 2, ''), l:right_width)

        let l:candidate.abbr= l:left . l:center . l:right
    endfor

    return l:candidates
endfunction

function! unite#filters#converter_mave_tabular#define()
    return [deepcopy(s:tabular)]
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
