Next Text Object Vim Plugin
========

This Vim plugin allows you to search forwards or backwards text objects rather than requiring that you be inside them.  It is based on a function that I snagged from Steve Losh's vimrc, with some modifications.

Works for the following text objects:
(, [, {, ', "

Input:
 
    din'  -> delete in next single quotes                

Result:

    foo = bar('spam')
    C
    foo = bar('')


