class FindAndTillInputElement extends HTMLDivElement
  createdCallback: ->
    @className = "find-and-till-input"
    @editorContainer = document.createElement("div")
    @editorContainer.className = "editor-container"
    @appendChild(@editorContainer)

  initialize: (@mainEditor, @callback) ->
    @editorElement = document.createElement "atom-text-editor"
    @editorElement.classList.add('editor')
    @editorElement.getModel().setMini(true)
    @editorElement.setAttribute('mini', '')
    @editorContainer.appendChild(@editorElement)

    @panel = atom.workspace.addBottomPanel(item: this, priority: 100)
    @mainEditor.findAndTillInputView = @editorElement

    @focus()
    @handleEvents()

    this

  focus: ->
    @editorElement.focus()

  handleEvents: ->
    @editorElement.getModel().getBuffer().onDidChange (e) =>
      @confirm() if e.newText

    atom.commands.add(@editorElement, 'core:confirm', @confirm.bind(this))
    atom.commands.add(@editorElement, 'core:cancel', @cancel.bind(this))
    atom.commands.add(@editorElement, 'blur', @cancel.bind(this))

  confirm: ->
    @value = @editorElement.getModel().getText()
    @callback(@value)
    @removePanel()

  cancel: ->
    @removePanel()

  removePanel: ->
    atom.workspace.getActivePane().activate()
    @panel.destroy()

module.exports =
  document.registerElement("find-and-till-input"
    extends: "div"
    prototype: FindAndTillInputElement.prototype)
