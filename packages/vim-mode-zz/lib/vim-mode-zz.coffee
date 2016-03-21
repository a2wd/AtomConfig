module.exports =
    activate: ->
        atom.commands.add('atom-text-editor', {
            'vim-mode-zz:close': => @close()
            'vim-mode-zz:saveAndClose': => @saveAndClose()
        })

    close: ->
        pack = atom.packages.activePackages['tree-view']
        treeView = pack?.mainModule.treeView

        selected = treeView?.selectedEntry()

        atom.workspace.getActivePaneItem()?.destroy()

        if treeView and !atom.workspace.getActivePane().getActiveItem()
            treeView.selectEntry(selected)
            treeView.show()

    saveAndClose: ->
        editor = atom.workspace.getActiveTextEditor()
        editor.save() if editor.getPath() and editor.isModified()
        @close()
