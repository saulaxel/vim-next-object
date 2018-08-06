Next Text Object Vim Plugin
========

This Vim plugin allows you to search forwards or backwards text objects rather than requiring that you be inside them.  It is based on a svermeulen repository, in turn snagged from Steve Losh's vimrc, with some modifications.

The plugin by default uses the letters 'n', 'l' and maps <C-l> and <C-h>. This can be configured.

Works for the following text objects:
(, [, {, ', "

In conjunction with operators, allows to make commands as:
 * din(   ->   delete inside next pair of bracket
 * dip}   ->   delete inside previous pair of brackets
 * dap"   ->   delete around previous string

# Features
----------

* Operate in next/previous text object

        Original text ('|' represents cursor position in normal mode):

            |foo = bar('span')

        Input keys:

            foo = bar

        Result:

            foo = bar('|')

* Select around previously used object

        Original text (after using 'in{' text objec text objectt):

            fun1()
            {
                # text
            }
            |
            fun2()
            {
                # text
            }

        Input key 1:

            <C-h>

        Output 1 (▒ means start and end of selection):

            fun1()
            {▒
                # text
            ▒}

            fun2()
            {
                # text
            }

        Input key 2:

            <C-l>

        Output 2;

            fun1()
            {
                # text
            }

            fun2()
            {▒
                # text
            ▒}

Installation
-----------

Download repository and copy every in the corresponding folders or just use a plugin manager as:

Vundle:
Add to your .vimrc:

    Plugin 'saulaxel/vim-next-object'

Plug:
Add to your .vimrc:

    Plug 'saulaxel/vim-next-object'

Configuration
-------------

 * Change next/previous shortcuts

     let g:next_object_next_letter =  'n'
     let g:next_object_prev_letter = 'p'

 * Change shortcuts for selecting previously used objects

     let g:next_object_select_next = "<C-l>"
     let g:next_object_select_prev = "<C-h>"
