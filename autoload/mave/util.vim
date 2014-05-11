let s:save_cpo= &cpo
set cpo&vim

function! mave#util#sync_exec(command)
    let l:process= vimproc#popen2(a:command)

    let l:buffer= ''
    while !l:process.stdout.eof
        let l:buffer.= l:process.stdout.read(128)

        while match(l:buffer, '\r\=\n') != -1
            let l:line= matchstr(l:buffer, '^.*\r\=\n')
            echo l:line
            let l:buffer= substitute(l:buffer, '^.*\r\=\n', '', '')
        endwhile
    endwhile
    if !empty(l:buffer)
        echo l:buffer
    endif

    call l:process.stdout.close()
    call l:process.waitpid()
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
