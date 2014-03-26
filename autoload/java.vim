
function! java#JumpToJavaTest()

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
                let folder = expand('%:h')
                if !isdirectory(folder) && confirm("Folder not exist: " . folder . ". Create now? ", "&yes\n&no", 1) == 1
                    call mkdir(folder, 'p')
                endif
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

function! GuessPackage()

    if (!exists("g:src_java_folders"))
        let g:src_java_folders="src/main/java:src/test/java"
    endif
    let folders = split(g:src_java_folders, ':', 1)

    let packageexpr = expand('%:p:h')
    let i1 = len(getcwd())
    let i2 = -1
    for folder in folders
        let i3 = stridx(packageexpr, folder, i1)
        if i3 > -1 && i3 + strlen(folder) > i2
            let i2 = i3 + strlen(folder)
        endif
    endfor
    let packageexpr = (i2 > -1 ? strpart(packageexpr, i2) : strpart(packageexpr, i1))
    if stridx(packageexpr, '/') == 0
        let packageexpr = strpart(packageexpr, 1)
    endif
    if strlen(packageexpr) > 0
        let packageexpr = "package ". substitute(packageexpr, "\/", ".", "g") . ";"
    endif
    return packageexpr
endfunction


function! java#DefaultPackageInfoContent()
    return "normal a\/**\n\n@author Trung Phan\n\n\/\n". GuessPackage() . "\<Esc>gg"
endfunction


function! java#DefaultJavaContent()
    let packageexpr = GuessPackage() |
    let importexpr = (expand('%:t') =~ ".*Test" ? "import org.junit.*;\nimport static org.junit.Assert.*;\n\n" : "") |
    return "normal O". (strlen(packageexpr)>0? packageexpr . "\n\n" : "") . importexpr . "\/**\n\n@author Trung Phan\n\n\/\npublic class " . expand('%:t:r') . " {\n}\<Esc>kW" |
endfunction
