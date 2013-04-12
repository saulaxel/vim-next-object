
" Motion for "next/last object".  "Last" here means "previous", not "final".
" Unfortunately the "p" motion was already taken for paragraphs.
"
" Next acts on the next object of the given type in the current line, last acts
" on the previous object of the given type in the current line.
"
" Currently only works for (, [, {, ', and ".
"
" Example:
" din'  -> delete in next single quotes                foo = bar('spam')
"                                                      C
"                                                      foo = bar('')

noremap <plug>AroundNextMap :<c-u>call <SID>NextTextObject('a', 'f', 'AroundNextMap')<cr>
noremap <plug>InnerNextMap :<c-u>call <SID>NextTextObject('i', 'f', 'InnerNextMap')<cr>
noremap <plug>AroundLastMap :<c-u>call <SID>NextTextObject('a', 'F', 'AroundLastMap')<cr>
noremap <plug>InnerLastMap :<c-u>call <SID>NextTextObject('i', 'F', 'InnerLastMap')<cr>

nmap na <plug>AroundNextMap
omap na <plug>AroundNextMap
xmap na <plug>AroundNextMap

nmap ni <plug>InnerNextMap
omap ni <plug>InnerNextMap
xmap ni <plug>InnerNextMap

nmap la <plug>AroundLastMap
omap la <plug>AroundLastMap
xmap la <plug>AroundLastMap

nmap li <plug>InnerLastMap
omap li <plug>InnerLastMap
xmap li <plug>InnerLastMap

function! s:NextTextObject(motion, dir, plugName)
    let c = nr2char(getchar())

    " Commented out to train on new keys, uncomment when it's learned
    "if c ==# "(" || c ==# ")" || c ==# "b" " b = brackets
    if c ==# "b" " b = brackets
        call s:SelectNextObject("(", ")", a:motion, a:dir)

    "elseif c ==# "{" || c ==# "}" || c ==# "c" " c = curly braces
    elseif c ==# "c" " c = curly braces
        call s:SelectNextObject("{", "}", a:motion, a:dir)

    "elseif c ==# "[" || c ==# "]" || c ==# "r" " s is taken by sentence, r = range
    elseif c ==# "r" " s is taken by sentence, r = range
        call s:SelectNextObject("[", "]", a:motion, a:dir)

    "elseif c ==# "\"" || c ==# "'"
    elseif c ==# "q"
        call s:SelectNextObject("\"", "\"", a:motion, a:dir)

    elseif c ==# "'"
        call s:SelectNextObject(c, c, a:motion, a:dir)

    else 
        echom "Invalid text object"
        return
    endif

    call repeat#motion("\<plug>".a:plugName.c, -1)
endfunction

function! s:CountCharsBehind(char, col, line)
    let i=0
    let cnt=0
    while i < a:col && i < strlen(a:line)
        if a:line[i] ==# a:char
            let cnt += 1
        endif
        let i += 1
    endwhile
    return cnt
endfunction

function! s:CountCharsInFront(char, col, line)
    let i=strlen(a:line)-1
    let cnt=0
    while i > a:col && i >= 0
        if a:line[i] ==# a:char
            let cnt += 1
        endif
        let i -= 1
    endwhile
    return cnt
endfunction

function! s:SelectNextObject(openChar, closeChar, motion, dir)

    let goForward = (a:dir ==# "f")
    let firstChar = goForward ? a:openChar : a:closeChar
    let lastChar = goForward ? a:closeChar : a:openChar

    exe 'normal! mz'
    let matchCount = 0

    while 1
        exe "normal! ".a:dir.firstChar

        let lineStr = getline('.')
        let lineCol = col('.')-1

        if lineStr[lineCol] ==# firstChar

            if a:openChar ==# a:closeChar

                let cnt = s:CountCharsInFront(a:openChar, lineCol, lineStr)

                if cnt % 2
                    " Odd number in front, so stop
                    break
                elseif cnt > 0
                    " Repeat on current line 
                    continue
                endif
            else
                break
            endif
        endif

        if (goForward && line('.') ==# line('$')) || (!goForward && line('.') == 1)
            exe 'normal! `z'
            echom "No match found"
            return
        endif

        if goForward
            exe "normal! j0"
        else
            exe "normal! k$"
        endif
    endwhile

    " Check if the object is empty
    if lineStr[lineCol+1] ==# lastChar
        " If our custom text object ends with text visually selected then that text is 
        " operated on
        " If it doesn't then vim will operate on the range from the old cursor position
        " to the new one
        " This is a problem because we want to move the cursor between brackets when they are empty
        " So create a dummy character and select that.  This will allow din( to work.
        " It means that vin( will create the character but I don't see another option, 
        " also, there's no reason to do vin( if the range is empty anyway
        exe "normal! a "
        exe "normal! v"
        return
    endif

    if a:openChar ==# a:closeChar
        let line = getline(".")
        let col = col('.') - 1

        if goForward
            let cnt = s:CountCharsBehind(a:openChar, col, line)
        else
            let cnt = s:CountCharsInFront(a:openChar, col, line)
        endif

        " Search again to avoid selecting the one we are in
        if cnt % 2
            exe "normal! ;"
        endif
    endif

    exe 'SSU'
    exe "normal! v".a:motion.a:openChar
endfunction
