EditorState = require './editor-state'

describe "Find and Till", ->
  [editor, editorView] = []

  beforeEach ->
    expect(atom.packages.isPackageActive("find-and-till")).toBe false

    waitsForPromise -> atom.workspace.open()
    runs ->
      editor = atom.workspace.getActiveTextEditor()
      editorView = atom.views.getView(editor)
      workspaceElement = atom.views.getView(atom.workspace)
      jasmine.attachToDOM(workspaceElement)

  describe "find", ->
    it "moves after the char pressed", ->
      setState "tes[0]ting 1234"
      sendCommand "find-and-till:find", "g"
      expectStateToBe "testing[0] 1234"

      setState "tes[0]ting 1234"
      sendCommand "find-and-till:find-backwards", "t"
      expectStateToBe "[0]testing 1234"

    it "can move up to the last charater", ->
      setState "[0]test 1234"
      sendCommand "find-and-till:find", "4"
      expectStateToBe "test 1234[0]"

    it "handles multiple cursors", ->
      setState(
        "zz aa[0]aa zz"
        "zz bb[1]bb zz"
      )
      sendCommand "find-and-till:find", "z"
      expectStateToBe "zz aaaa z[0]z\nzz bbbb z[1]z"

      setState(
        "zz aa[0]aa zz"
        "zz bb[1]bb zz"
      )
      sendCommand "find-and-till:find-backwards", "z"
      expectStateToBe "z[0]z aaaa zz\nz[1]z bbbb zz"

    it "can select text including the char pressed", ->
      setState "tes[0]ting 1234"
      sendCommand "find-and-till:select-find", "g"
      expectStateToBe "tes(0)ting[0] 1234"

      setState "tes[0]ting 1234"
      sendCommand "find-and-till:select-find-backwards", "t"
      expectStateToBe "(0)tes[0]ting 1234"

    it "can select with multiple cursors", ->
      setState(
        "zz aa[0]aa zz"
        "zz bb[1]bb zz"
      )
      sendCommand "find-and-till:select-find", "z"
      expectStateToBe "zz aa(0)aa z[0]z\nzz bb(1)bb z[1]z"

      setState(
        "zz aa[0]aa zz"
        "zz bb[1]bb zz"
      )
      sendCommand "find-and-till:select-find-backwards", "z"
      expectStateToBe "z(0)z aa[0]aa zz\nz(1)z bb[1]bb zz"

  describe "till", ->
    it "moves before the char pressed", ->
      setState "tes[0]ting 1234"
      sendCommand "find-and-till:till", "g"
      expectStateToBe "testin[0]g 1234"

      setState "tes[0]ting 1234"
      sendCommand "find-and-till:till-backwards", "t"
      expectStateToBe "t[0]esting 1234"

    it "handles multiple cursors", ->
      setState(
        "zz aa[0]aa zz"
        "zz bb[1]bb zz"
      )
      sendCommand "find-and-till:till", "z"
      expectStateToBe "zz aaaa [0]zz\nzz bbbb [1]zz"

      setState(
        "zz aa[0]aa zz"
        "zz bb[1]bb zz"
      )
      sendCommand "find-and-till:till-backwards", "z"
      expectStateToBe "zz[0] aaaa zz\nzz[1] bbbb zz"

    it "can select text excluding the char pressed", ->
      setState "tes[0]ting 1234"
      sendCommand "find-and-till:select-till", "g"
      expectStateToBe "tes(0)tin[0]g 1234"

      setState "tes[0]ting 1234"
      sendCommand "find-and-till:select-till-backwards", "t"
      expectStateToBe "t(0)es[0]ting 1234"

    it "can select with multiple cursors", ->
      setState(
        "zz aa[0]aa zz"
        "zz bb[1]bb zz"
      )
      sendCommand "find-and-till:select-till", "z"
      expectStateToBe "zz aa(0)aa [0]zz\nzz bb(1)bb [1]zz"

      setState(
        "zz aa[0]aa zz"
        "zz bb[1]bb zz"
      )
      sendCommand "find-and-till:select-till-backwards", "z"
      expectStateToBe "zz(0) aa[0]aa zz\nzz(1) bb[1]bb zz"

  setState = (state...) ->
    state = state.join "\n"
    runs -> EditorState.set(editor, state)

  sendCommand = (command, char) ->
    activationPromise = atom.packages.activatePackage("find-and-till")
    runs -> atom.commands.dispatch editorView, command
    waitsForPromise -> activationPromise
    # waitsFor -> editor.findAndTillInputView
    runs -> editor.findAndTillInputView.getModel().setText(char)
    # waitsFor -> not editor.findAndTillInputView

  expectStateToBe = (state) ->
    runs -> expect(EditorState.get(editor)).toBe state
