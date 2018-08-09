
" Motion for "next/last object". Here last means "previos" because p object
" was already taken for paragraphs
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

scriptencoding utf-8

if exists('g:next_object_loaded')
    finish
endif
let g:next_object_loaded = 1

noremap <silent> <Plug>AroundNextMap :<C-u>call <SID>NextTextObject('a', 'f', 'AroundNextMap', '')<CR>
noremap <silent> <Plug>InnerNextMap  :<C-u>call <SID>NextTextObject('i', 'f', 'InnerNextMap', '')<CR>
noremap <silent> <Plug>AroundLastMap :<C-u>call <SID>NextTextObject('a', 'F', 'AroundLastMap', '')<CR>
noremap <silent> <Plug>InnerLastMap  :<C-u>call <SID>NextTextObject('i', 'F', 'InnerLastMap', '')<CR>

noremap <silent> <Plug>RepeatNextObject     :<C-u>call <SID>RepeatNextObject()<CR>
noremap <silent> <Plug>RepeatPreviousObject :<C-u>call <SID>RepeatPreviousObject()<CR>

if !exists('g:next_object_next_letter')
    omap an <Plug>AroundNextMap
    xmap an <Plug>AroundNextMap

    omap in <Plug>InnerNextMap
    xmap in <Plug>InnerNextMap
else
    execute 'omap a' . g:next_object_next_letter . ' <Plug>AroundNextMap'
    execute 'xmap a' . g:next_object_next_letter . ' <Plug>AroundNextMap'

    execute 'omap i' . g:next_object_next_letter . ' <Plug>InnerNextMap'
    execute 'xmap i' . g:next_object_next_letter . ' <Plug>InnerNextMap'
endif

if !exists('g:next_object_prev_letter')
    omap al <Plug>AroundLastMap
    xmap al <Plug>AroundLastMap

    omap il <Plug>InnerLastMap
    xmap il <Plug>InnerLastMap
else
    execute 'omap a' . g:next_object_prev_letter . ' <Plug>AroundLastMap'
    execute 'xmap a' . g:next_object_prev_letter . ' <Plug>AroundLastMap'

    execute 'omap i' . g:next_object_prev_letter . ' <Plug>InnerLastMap'
    execute 'xmap i' . g:next_object_prev_letter . ' <Plug>InnerLastMap'
endif

if !exists('g:next_object_select_next')
    xmap <c-l> <Plug>RepeatNextObject
else
    execute 'xmap ' . g:next_object_select_next . ' <Plug>RepeatNextObject'
endif

if !exists('g:next_object_select_prev')
    xmap <c-h> <Plug>RepeatPreviousObject
else
    execute 'xmap ' . g:next_object_select_prev . ' <Plug>RepeatPreviousObject'
endif

if !exists('g:next_object_wrap_file')
    let g:next_object_wrap_file = 0
endif

let s:lastMotion      = 'i'
let s:lastTextObjType = 'b'

function! s:RepeatNextObject()
    call s:NextTextObject(s:lastMotion, 'f', '', s:lastTextObjType)
endfunction

function! s:RepeatPreviousObject()
    call s:NextTextObject(s:lastMotion, 'F', '', s:lastTextObjType)
endfunction

function! s:NextTextObject(motion, dir, plugName, objType)

    let l:c = a:objType
    if empty(l:c)
        let l:c = nr2char(getchar())
    endif

    if stridx('b()', l:c) != -1
        call s:SelectNextObject('(', ')', a:motion, a:dir)
    elseif stridx('cB{}', l:c) != -1
        call s:SelectNextObject('{', '}', a:motion, a:dir)
    elseif stridx('r[]', l:c) != -1 " s is taken by sentence, r = range
        call s:SelectNextObject('[', ']', a:motion, a:dir)
    elseif stridx('q"', l:c) != -1
        call s:SelectNextObject('"', '"', a:motion, a:dir)
    elseif l:c ==# "'"
        call s:SelectNextObject("'", "'", a:motion, a:dir)
    elseif stridx('g<>', l:c) != -1
        call s:SelectNextObject('<', '>', a:motion, a:dir)
    else
        echomsg 'Invalid text object'
        return
    endif

    let s:lastMotion      = a:motion
    let s:lastTextObjType = l:c

    "if !empty(a:plugName)
    "    call repeat#motion("\<Plug>" . a:plugName . l:c, -1)
    "endif
endfunction

function! s:CountCharsBehind(char, col, line)
    let l:i   = 0
    let l:cnt = 0
    while (l:i < a:col) && (l:i < strlen(a:line))
        if a:line[l:i] ==# a:char
            let l:cnt += 1
        endif
        let l:i += 1
    endwhile
    return l:cnt
endfunction

function! s:CountCharsInFront(char, col, line)
    let l:i = strlen(a:line) - 1
    let l:cnt = 0
    while (l:i > a:col) && (l:i >= 0)
        if a:line[l:i] ==# a:char
            let l:cnt += 1
        endif
        let l:i -= 1
    endwhile
    return l:cnt
endfunction

function! s:LastFileLine(goForward)
    if a:goForward
        return line('.') == line('$')
    else
        return line('.') == 1
    endif
endfunction

function! s:SelectNextObject(openChar, closeChar, motion, dir)

    let l:startingLine = line('.')
    let l:goForward = (a:dir ==# 'f')
    let l:firstChar = l:goForward ? a:openChar  : a:closeChar
    let l:lastChar  = l:goForward ? a:closeChar : a:openChar

    mark z
    let l:matchCount = 0

    while 1
        let l:lineCol = col('.') - 1
        let l:lineStr = getline('.')

        " Bug fix: also catch cases where it is the last character
        if l:lineStr[l:lineCol] !=# l:firstChar
            execute 'normal! ' . a:dir . l:firstChar
            let l:lineCol = col('.') - 1
        endif

        if l:lineStr[l:lineCol] ==# l:firstChar
            if a:openChar ==# a:closeChar

                let l:cnt = (l:goForward ?
                        \ s:CountCharsInFront(a:openChar, l:lineCol, l:lineStr) :
                        \ s:CountCharsBehind(a:openChar, l:lineCol, l:lineStr))

                if l:cnt % 2
                    " Odd number in front, so stop
                    break
                elseif l:cnt > 0
                    " Repeat on current after advancing one char
                    execute 'normal! ' . (l:goForward ? 'l' : 'h')
                    continue
                endif
            else
                break
            endif
        endif

        let l:justWrappedFile = 0
        if g:next_object_wrap_file
            if (l:goForward && line('.') + 1 == l:startingLine)
                \ || (!l:goForward && line('.') - 1 == l:startingLine)
                normal! `z
                delm z
                echomsg 'No match found'
                return
            endif

            if s:LastFileLine(l:goForward)
                execute 'normal! ' . (l:goForward ? 'gg0' : 'G$')
                let l:justWrappedFile = 1
            endif
        else
            if s:LastFileLine(l:goForward)
                normal! `z
                delm z
                echomsg 'No match found'
                return
            endif
        endif

        if !l:justWrappedFile
            if l:goForward
                normal! j0
            else
                normal! k$
            endif
        endif
    endwhile

    " Check if the object is empty
    if (l:goForward && l:lineStr[l:lineCol + 1] ==# l:lastChar)
                \|| (!l:goForward && l:lineStr[l:lineCol - 1] ==# l:lastChar)
        " If our custom text object ends with text visually selected then that text is
        " operated on
        " If it doesn't then vim will operate on the range from the old cursor position
        " to the new one
        " This is a problem because we want to move the cursor between brackets when they are empty
        " So create a dummy character and select that.  This will allow din( to work.
        " It means that vin( will create the character but I don't see another option,
        " also, there's no reason to do vin( if the range is empty anyway
        if l:goForward
            normal! a
        else
            normal! i
        endif
        normal! v
        delm z
        return
    endif

    if a:openChar ==# a:closeChar
        let l:line = getline('.')
        let l:col = col('.') - 1

        if l:goForward
            let l:cnt = s:CountCharsBehind(a:openChar, l:col, l:line)
        else
            let l:cnt = s:CountCharsInFront(a:openChar, l:col, l:line)
        endif

        " Search again to avoid selecting the one we are in
        if l:cnt % 2
            " Advance to next (cant use ';' because maybe the
            " first search has not happened)
            execute 'normal! ' . a:dir . l:lastChar
        endif
    endif

    execute 'normal! v' . a:motion . a:openChar
    delm z
endfunction
