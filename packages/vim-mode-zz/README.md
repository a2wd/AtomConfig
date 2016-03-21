# vim-mode-zz package

Allows to close opened tabs/splits/windows with Vim's ZZ command as you would
do in Vim. Works **only** in Code Editor tabs

## Features
* When last editor is closed the focus is activated on tree view if it exists
and cursor is on the currently selected item
* Non-Vim ZQ binding which acts like :q! (since ex-mode q doesn't restore focus
on the tree view)
* Doesn't require vim-mode (but why would you use this package then?)
* Doesn't require tree view to be enabled
