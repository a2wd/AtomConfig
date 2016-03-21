describe "Language-Haskell", ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage("language-haskell")

    runs ->
      grammar = atom.grammars.grammarForScopeName("source.haskell")

  it "parses the grammar", ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe "source.haskell"

  describe "chars", ->
    it 'tokenizes general chars', ->
      chars = ['a', '0', '9', 'z', '@', '0', '"']

      for scope, char of chars
        {tokens} = grammar.tokenizeLine("'" + char + "'")
        expect(tokens).toEqual [
          {value:"'", scopes: ["source.haskell", 'string.quoted.single.haskell', "punctuation.definition.string.begin.haskell"]}
          {value: char, scopes: ["source.haskell", 'string.quoted.single.haskell']}
          {value:"'", scopes: ["source.haskell", 'string.quoted.single.haskell', "punctuation.definition.string.end.haskell"]}
        ]

    it 'tokenizes escape chars', ->
      escapeChars = ['\\t', '\\n', '\\\'']
      for scope, char of escapeChars
        {tokens} = grammar.tokenizeLine("'" + char + "'")
        expect(tokens).toEqual [
          {value:"'", scopes: ["source.haskell", 'string.quoted.single.haskell', "punctuation.definition.string.begin.haskell"]}
          {value: char, scopes: ["source.haskell", 'string.quoted.single.haskell', 'constant.character.escape.haskell']}
          {value:"'", scopes: ["source.haskell", 'string.quoted.single.haskell', "punctuation.definition.string.end.haskell"]}
        ]

  describe "strings", ->
    it "tokenizes single-line strings", ->
      {tokens} = grammar.tokenizeLine '"abcde\\n\\EOT\\EOL"'
      expect(tokens).toEqual  [
        { value : '"', scopes : [ 'source.haskell', 'string.quoted.double.haskell', 'punctuation.definition.string.begin.haskell' ] }
        { value : 'abcde', scopes : [ 'source.haskell', 'string.quoted.double.haskell' ] }
        { value : '\\n', scopes : [ 'source.haskell', 'string.quoted.double.haskell', 'constant.character.escape.haskell' ] }
        { value : '\\EOT', scopes : [ 'source.haskell', 'string.quoted.double.haskell', 'constant.character.escape.haskell' ] }
        { value : '\\EOL', scopes : [ 'source.haskell', 'string.quoted.double.haskell' ] }
        { value : '"', scopes : [ 'source.haskell', 'string.quoted.double.haskell', 'punctuation.definition.string.end.haskell' ] }
      ]


  describe "backtick function call", ->
    it "finds backtick function names", ->
      {tokens} = grammar.tokenizeLine("\`func\`")
      expect(tokens[0]).toEqual value: '`', scopes: ['source.haskell', 'keyword.operator.function.infix.haskell','punctuation.definition.entity.haskell']
      expect(tokens[1]).toEqual value: 'func', scopes: ['source.haskell', 'keyword.operator.function.infix.haskell']
      expect(tokens[2]).toEqual value: '`', scopes: ['source.haskell', 'keyword.operator.function.infix.haskell','punctuation.definition.entity.haskell']

  describe "keywords", ->
    controlKeywords = ['case', 'of', 'in', 'where', 'if', 'then', 'else']

    for scope, keyword of controlKeywords
      it "tokenizes #{keyword} as a keyword", ->
        {tokens} = grammar.tokenizeLine(keyword)
        expect(tokens[0]).toEqual value: keyword, scopes: ['source.haskell', 'keyword.control.haskell']

  describe "operators", ->
    it "tokenizes the / arithmetic operator when separated by newlines", ->
      lines = grammar.tokenizeLines """
        1
        / 2
      """
      expect(lines).toEqual  [
          [
            { value : '1', scopes : [ 'source.haskell', 'constant.numeric.haskell' ] }
          ],
          [
            { value : '/', scopes : [ 'source.haskell', 'keyword.operator.haskell' ] }
            { value : ' ', scopes : [ 'source.haskell' ] }
            { value : '2', scopes : [ 'source.haskell', 'constant.numeric.haskell' ] }
          ]
        ]

  it "tokenizes {-  -} comments", ->
    {tokens} = grammar.tokenizeLine('{--}')

    expect(tokens).toEqual [
        { value : '{-', scopes : [ 'source.haskell', 'comment.block.haskell', 'punctuation.definition.comment.haskell' ] }
        { value : '-}', scopes : [ 'source.haskell', 'comment.block.haskell' ] }
      ]

    {tokens} = grammar.tokenizeLine('{- foo -}')
    expect(tokens).toEqual  [
        { value : '{-', scopes : [ 'source.haskell', 'comment.block.haskell', 'punctuation.definition.comment.haskell' ] }
        { value : ' foo ', scopes : [ 'source.haskell', 'comment.block.haskell' ] }
        { value : '-}', scopes : [ 'source.haskell', 'comment.block.haskell' ] }
      ]

  describe "ids", ->
    it 'handles type_ids', ->
      typeIds = ['Char', 'Data', 'List', 'Int', 'Integral', 'Float', 'Date']

      for scope, id of typeIds
        {tokens} = grammar.tokenizeLine(id)
        expect(tokens[0]).toEqual value: id, scopes: ['source.haskell', 'entity.name.tag.haskell']

  describe ':: declarations', ->
    it 'parses newline declarations', ->
      data = 'function :: Type -> OtherType'
      {tokens} = grammar.tokenizeLine(data)
      expect(tokens).toEqual [
          { value : 'function', scopes : [ 'source.haskell', 'meta.function.type-declaration.haskell', 'entity.name.function.haskell' ] }
          { value : ' ', scopes : [ 'source.haskell', 'meta.function.type-declaration.haskell' ] }
          { value : '::', scopes : [ 'source.haskell', 'meta.function.type-declaration.haskell', 'keyword.other.double-colon.haskell' ] }
          { value : ' ', scopes : [ 'source.haskell', 'meta.function.type-declaration.haskell', 'meta.type-signature.haskell' ] }
          { value : 'Type', scopes : [ 'source.haskell', 'meta.function.type-declaration.haskell', 'meta.type-signature.haskell', 'entity.name.type.haskell' ] }
          { value : ' ', scopes : [ 'source.haskell', 'meta.function.type-declaration.haskell', 'meta.type-signature.haskell' ] }
          { value : '->', scopes : [ 'source.haskell', 'meta.function.type-declaration.haskell', 'meta.type-signature.haskell', 'keyword.other.arrow.haskell' ] }
          { value : ' ', scopes : [ 'source.haskell', 'meta.function.type-declaration.haskell', 'meta.type-signature.haskell' ] }
          { value : 'OtherType', scopes : [ 'source.haskell', 'meta.function.type-declaration.haskell', 'meta.type-signature.haskell', 'entity.name.type.haskell' ] }
        ]

    it 'parses in-line parenthesised declarations', ->
      data = 'main = (putStrLn :: String -> IO ()) ("Hello World" :: String)'
      {tokens} = grammar.tokenizeLine(data)
      expect(tokens).toEqual [
        { value : 'main ', scopes : [ 'source.haskell' ] }
        { value : '=', scopes : [ 'source.haskell', 'keyword.operator.haskell' ] }
        { value : ' ', scopes : [ 'source.haskell' ] }
        { value : '(', scopes : [ 'source.haskell' ] }
        { value : 'putStrLn', scopes : [ 'source.haskell', 'support.function.prelude.haskell' ] }
        { value : ' ', scopes : [ 'source.haskell' ] }
        { value : '::', scopes : [ 'source.haskell', 'keyword.other.double-colon.haskell' ] }
        { value : ' ', scopes : [ 'source.haskell' ] }
        { value : 'String', scopes : [ 'source.haskell', 'support.class.prelude.haskell' ] }
        { value : ' ', scopes : [ 'source.haskell' ] }
        { value : '->', scopes : [ 'source.haskell', 'keyword.other.arrow.haskell' ] }
        { value : ' ', scopes : [ 'source.haskell' ] }
        { value : 'IO', scopes : [ 'source.haskell', 'support.class.prelude.haskell' ] }
        { value : ' ', scopes : [ 'source.haskell' ] }
        { value : '()', scopes : [ 'source.haskell', 'constant.language.unit.haskell' ] }
        { value : ')', scopes : [ 'source.haskell' ] }
        { value : ' ', scopes : [ 'source.haskell' ] }
        { value : '(', scopes : [ 'source.haskell' ] }
        { value : '"', scopes : [ 'source.haskell', 'string.quoted.double.haskell', 'punctuation.definition.string.begin.haskell' ] }
        { value : 'Hello World', scopes : [ 'source.haskell', 'string.quoted.double.haskell' ] }
        { value : '"', scopes : [ 'source.haskell', 'string.quoted.double.haskell', 'punctuation.definition.string.end.haskell' ] }
        { value : ' ', scopes : [ 'source.haskell' ] }
        { value : '::', scopes : [ 'source.haskell', 'keyword.other.double-colon.haskell' ] }
        { value : ' ', scopes : [ 'source.haskell' ] }
        { value : 'String', scopes : [ 'source.haskell', 'support.class.prelude.haskell' ] }
        { value : ')', scopes : [ 'source.haskell' ] }
      ]

    it 'parses in-line non-parenthesised declarations', ->
      data = 'main = putStrLn "Hello World" :: IO ()'
      {tokens} = grammar.tokenizeLine(data)
      expect(tokens).toEqual [
        { value : 'main ', scopes : [ 'source.haskell' ] }
        { value : '=', scopes : [ 'source.haskell', 'keyword.operator.haskell' ] }
        { value : ' ', scopes : [ 'source.haskell' ] }
        { value : 'putStrLn', scopes : [ 'source.haskell', 'support.function.prelude.haskell' ] }
        { value : ' ', scopes : [ 'source.haskell' ] }
        { value : '"', scopes : [ 'source.haskell', 'string.quoted.double.haskell', 'punctuation.definition.string.begin.haskell' ] }
        { value : 'Hello World', scopes : [ 'source.haskell', 'string.quoted.double.haskell' ] }
        { value : '"', scopes : [ 'source.haskell', 'string.quoted.double.haskell', 'punctuation.definition.string.end.haskell' ] }
        { value : ' ', scopes : [ 'source.haskell' ] }
        { value : '::', scopes : [ 'source.haskell', 'keyword.other.double-colon.haskell' ] }
        { value : ' ', scopes : [ 'source.haskell' ] }
        { value : 'IO', scopes : [ 'source.haskell', 'support.class.prelude.haskell' ] }
        { value : ' ', scopes : [ 'source.haskell' ] }
        { value : '()', scopes : [ 'source.haskell', 'constant.language.unit.haskell' ] }
      ]
