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
let s:M= mave#Vim_Message

let s:repo_search= {
\   'name': 'mave/search/repository',
\   'description': 'Search artifacts from maven central repository',
\}

function! s:repo_search.get_abbr(context, id)
    return printf("[%*s] %*s %*s %*s %s",
    \   10, a:id.p,
    \   20, a:id.g,
    \   20, a:id.a,
    \   10, a:id.latestVersion,
    \   join(a:id.ec, ','))
endfunction

function! s:repo_search.init(context)
    let a:context.nrows= 100
    let a:context.wait_time= 1.0
    let a:context.last_query= ''
    let a:context.last_time= reltime()
    return []
endfunction

function! s:repo_search.lazy_init(context, query)
    if a:query =~# '^\s*$' || a:query ==# a:context.last_query
        return {'reset': 0, 'candidates': []}
    endif
    let a:context.last_query= a:query
    if str2float(reltimestr(reltime(a:context.last_time))) < a:context.wait_time
        return {'reset': 0, 'candidates': []}
    endif
    let a:context.last_time= reltime()

    let response= s:H.request({
    \   'url': 'http://search.maven.org/solrsearch/select',
    \   'param': {
    \       'q':    a:query,
    \       'rows': a:context.nrows,
    \       'wt':   'json',
    \   },
    \})
    if !response.success
        call s:M.error(printf("mave: Got a HTTP Error (%s %s)", response.status, response.statusText))
        return {'reset': 0, 'candidates': []}
    endif

    " {
    "    "a" : "guice",
    "    "repositoryId" : "central",
    "    "versionCount" : 4,
    "    "p" : "jar",
    "    "timestamp" : 1419244680000,
    "    "text" : [
    "       "io.prometheus.client.examples",
    "       "guice",
    "       "-sources.jar",
    "       "-javadoc.jar",
    "       ".jar",
    "       ".pom"
    "    ],
    "    "g" : "io.prometheus.client.examples",
    "    "ec" : [
    "       "-sources.jar",
    "       "-javadoc.jar",
    "       ".jar",
    "       ".pom"
    "    ],
    "    "id" : "io.prometheus.client.examples:guice",
    "    "latestVersion" : "0.0.6"
    " },
    let data= s:J.decode(response.content)
    return {'reset': 1, 'candidates': data.response.docs}
endfunction

function! s:repo_search.accept(context, id)
    call milqi#exit()
    echomsg PP(a:id)
endfunction

function! milqi#mave#repo_search()
    return deepcopy(s:repo_search)
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
