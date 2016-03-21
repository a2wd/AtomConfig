FindAndTillInputElement = require './find-and-till-input-element'
{CompositeDisposable, Point, Range} = require 'atom'

reverse = (line, char, cursorPos) ->
  line.slice(0, cursorPos - 1).lastIndexOf(char)

forward = (line, char, cursorPos) ->
  line.indexOf(char, cursorPos + 1)

moveCursors = (editor, [[first], rest...]) ->
  editor.setCursorBufferPosition(first)
  rest.forEach ([cursor]) ->
    editor.addCursorAtBufferPosition(cursor)

selectToCursors = (editor, cursors) ->
  cursors.forEach ([next, prev]) ->
    editor.addSelectionForBufferRange(new Range(prev, next))

module.exports = FindAndTill =
  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-text-editor', 'find-and-till:find': => @find()
    @subscriptions.add atom.commands.add 'atom-text-editor', 'find-and-till:select-find': => @selectFind()
    @subscriptions.add atom.commands.add 'atom-text-editor', 'find-and-till:find-backwards': => @findBackwards()
    @subscriptions.add atom.commands.add 'atom-text-editor', 'find-and-till:select-find-backwards': => @selectFindBackwards()
    @subscriptions.add atom.commands.add 'atom-text-editor', 'find-and-till:till': => @till()
    @subscriptions.add atom.commands.add 'atom-text-editor', 'find-and-till:select-till': => @selectTill()
    @subscriptions.add atom.commands.add 'atom-text-editor', 'find-and-till:till-backwards': => @tillBackwards()
    @subscriptions.add atom.commands.add 'atom-text-editor', 'find-and-till:select-till-backwards': => @selectTillBackwards()

  deactivate: ->
    @subscriptions.dispose()

  till: -> @FindAndTill(0, forward, moveCursors)
  selectTill: -> @FindAndTill(0, forward, selectToCursors)
  tillBackwards: -> @FindAndTill(1, reverse, moveCursors)
  selectTillBackwards: -> @FindAndTill(1, reverse, selectToCursors)
  find: -> @FindAndTill(1, forward, moveCursors)
  selectFind: -> @FindAndTill(1, forward, selectToCursors)
  findBackwards: -> @FindAndTill(0, reverse, moveCursors)
  selectFindBackwards: -> @FindAndTill(0, reverse, selectToCursors)

  FindAndTill: (offset, finder, cursorHandler) ->
    return unless editor = atom.workspace.getActiveTextEditor()

    new FindAndTillInputElement().initialize editor, (text) ->
      return unless text
      char = text[0]

      newCursors = editor.getCursorBufferPositions().map (cursor) ->
        line = editor.lineTextForBufferRow(cursor.row)
        index = finder(line, char, cursor.column)
        return [cursor, cursor] unless index >= 0
        [new Point(cursor.row, index + offset), cursor]

      cursorHandler(editor, newCursors)
