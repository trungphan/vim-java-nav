
function! jump#JumpToJavaTest()

    if (!exists("g:jump_src_java_main"))
        let g:jump_src_java_main="/src/main/java"
    endif

    if (!exists("g:jump_src_java_test"))
        let g:jump_src_java_test="/src/test/java"
    endif

    if (expand("%:e") == "java")
        let currpath=expand("%:p:h")
        if (currpath =~ ".*" . g:jump_src_java_main . ".*" && expand("%:p:r") !~ ".*Test$" )
            let testpath=substitute(currpath, g:jump_src_java_main, g:jump_src_java_test, "")
            let testfilename=expand("%:t:r") . "Test.java"
            let testfile=testpath . "/" . testfilename
            if (bufexists(testfile))
                execute 'buffer ' . testfile
            elseif (filereadable(testfile) || confirm("Create test file: " . testfilename . "?", "&yes\n&no", 1) == 1)
                execute 'edit ' . testfile
            endif
        elseif (currpath =~ "." . g:jump_src_java_test . ".*")
            let mainpath=substitute(currpath, g:jump_src_java_test, g:jump_src_java_main, "")
            let mainfile=mainpath . "/" . substitute(expand("%:t:r"), "Test$", "", "") . ".java"
            if (bufexists(mainfile))
                execute 'buffer ' . mainfile
            else
                execute 'find ' . mainfile
            endif
        endif
    endif
endfunction

