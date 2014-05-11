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
let mave#Web_HTTP=     s:V.import('Web.HTTP')
let mave#Web_JSON=     s:V.import('Web.JSON')
let mave#OptionParser= s:V.import('OptionParser')
unlet s:V

function! mave#create_project(config)
    let l:archetype= get(a:config, 'archetype', {})

    let l:cmd= join([
    \       g:mave_config.mvn_command,
    \       '--batch-mode',
    \       'archetype:generate',
    \       '-DarchetypeGroupId=' . get(l:archetype, 'group_id', 'org.apache.maven.archetypes'),
    \       '-DarchetypeArtifactId=' . get(l:archetype, 'artifact_id', 'maven-archetype-quickstart'),
    \       '-DgroupId=' . a:config.group_id,
    \       '-DartifactId=' . a:config.artifact_id,
    \       '-Dversion=' . a:config.version,
    \   ],
    \   ' '
    \)

    call mave#util#sync_exec(l:cmd)
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
