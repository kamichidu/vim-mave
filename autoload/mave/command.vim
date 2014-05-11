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

let s:create_project_option_parser= mave#OptionParser.new()

call s:create_project_option_parser.on('--groupid=VALUE', 'specify new maven project group id')
call s:create_project_option_parser.on('--artifactid=VALUE', 'specify new maven project artifact id')
call s:create_project_option_parser.on('--version=VALUE', 'specify new maven project version', {'default': '0.0.0'})

function! mave#command#create_project(q_args)
    let l:args= s:create_project_option_parser.parse(a:q_args)

    let l:delegate= {
    \   'config': {
    \       'group_id':    l:args.groupid,
    \       'artifact_id': l:args.artifactid,
    \       'version':     l:args.version,
    \   },
    \}
    function! l:delegate.func(candidate)
        let self.config.archetype= {
        \   'group_id':    a:candidate.action__groupid,
        \   'artifact_id': a:candidate.action__artifactid,
        \}
        call mave#create_project(self.config)
    endfunction

    call unite#start([['mave/search/archetype-catalog']], {
    \   'source__delegate': l:delegate,
    \})
endfunction

function! mave#command#complete_create_project(arglead, cmdline, cursorpos)
    return s:create_project_option_parser.complete(a:arglead, a:cmdline, a:cursorpos)
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
" vim:fen:fdm=marker
