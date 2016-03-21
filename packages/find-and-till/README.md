# Find and Till [![Build Status](https://travis-ci.org/aaronjensen/atom-find-and-till.svg?branch=master)](https://travis-ci.org/aaronjensen/atom-find-and-till)

Quickly jump to the next character you type on your current line. If you've used Vim, it's just like `f` and `t` and also `vf` and `vt` but without needing vim-mode.

![find-and-till](https://cloud.githubusercontent.com/assets/8588/8742523/26480284-2c1b-11e5-86c7-be78a28e6289.gif)

Find (jump to just after letter) and Till (jump to just before character) are both supported in either the forward direction or the reverse and you can select while doing it.

Multiple cursors are supported.

There are currently no default bindings, but here are some examples:

```cson
'atom-text-editor':
  'ctrl-s': 'find-and-till:till'
  'ctrl-shift-s': 'find-and-till:select-till'
  'ctrl-r': 'find-and-till:till-backwards'
  'ctrl-shift-r': 'find-and-till:select-till-backwards'
  'ctrl-alt-s': 'find-and-till:find'
  'ctrl-alt-shift-s': 'find-and-till:select-find'
  'ctrl-alt-r': 'find-and-till:find-backwards'
  'ctrl-alt-shift-r': 'find-and-till:select-find-backwards'
```

### Todo

* Come up with sensible defaults
* Learn how to write specs?
