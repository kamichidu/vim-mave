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

let s:H= mave#Web_HTTP
let s:J= mave#Web_JSON

" mave/search/repository {{{
let s:repo_search= {
\   'name': 'mave/search/repository',
\   'description': 'search maven central repository',
\   'filters': ['converter_mave_tabular'],
\}

function! s:repo_search.gather_candidates(args, context)
    if empty(a:args) || len(a:args) != 1
        call s:error('only single argument required')
        return []
    endif

    let l:response= s:H.request({
    \   'url': 'http://search.maven.org/solrsearch/select',
    \   'param': {
    \       'q':    a:args[0],
    \       'rows': 100,
    \       'wt':   'json',
    \   },
    \})

    if !l:response.success
        call s:error('mave: http error: %s %s', l:response.status, l:response.statusText)
        return []
    endif

    let l:json= s:J.decode(l:response.content)

    return map(l:json.response.docs, "
    \   {
    \       'word': v:val.id,
    \       'abbr': printf('[%s] | %s:%s | (%s)', v:val.p, v:val.g, v:val.a, v:val.latestVersion),
    \       'source__group_id':       v:val.g,
    \       'source__artifact_id':    v:val.a,
    \       'source__packaging':      v:val.p,
    \       'source__latest_version': v:val.latestVersion,
    \   }
    \")
endfunction
" }}}

" mave/search/archetype-catalog {{{
let s:archetype_catalog_search= {
\   'name': 'mave/search/archetype-catalog',
\   'description': 'search maven archetype catalog',
\}

function! s:archetype_catalog_search.gather_candidates(args, context)
    let l:bin_path= globpath(&runtimepath, 'bin/archetype-catalog.pl')
    let l:result= vimproc#system('perl ' . l:bin_path)
    let l:archetypes= s:J.decode(l:result)

    return map(l:archetypes, "
    \   {
    \       'word': printf('%s:%s (%s)', v:val.group_id, v:val.artifact_id, v:val.version),
    \       'kind': 'mave/archetype',
    \       'info': get(v:val, 'description', ''),
    \       'action__groupid':       v:val.group_id,
    \       'action__artifactid':    v:val.artifact_id,
    \       'action__delegate':      get(a:context, 'source__delegate', {}),
    \   }
    \")
endfunction
" }}}

function! unite#sources#mave#define()
    return [
    \   deepcopy(s:repo_search),
    \   deepcopy(s:archetype_catalog_search),
    \]
endfunction

function! s:info(msg)
    echomsg a:msg
endfunction

function! s:warn(msg)
    echohl WarningMsg
    echomsg a:msg
    echohl None
endfunction

function! s:error(msg)
    echohl ErrorMsg
    echomsg a:msg
    echohl None
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
" vim:fen:fdm=marker
