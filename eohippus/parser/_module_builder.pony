use ast = "../ast"
use ".."

class _ModuleBuilder
  let _trivia: _TriviaBuilder
  let _lexer: _LexerBuilder
  let _literal: _LiteralBuilder

  var _module: (NamedRule | None) = None
  var _docstring: (NamedRule | None) = None
  var _using: (NamedRule | None) = None
  var _typedef: (NamedRule | None) = None

  new create(trivia: _TriviaBuilder, lexer: _LexerBuilder,
    literal: _LiteralBuilder)
  =>
    _trivia = trivia
    _lexer = lexer
    _literal = literal

  fun ref module(): NamedRule =>
    match _module
    | let r: NamedRule => r
    else
      let tr = Variable
      let ds = Variable
      let us = Variable
      let td = Variable

      let trivia_trivia = _trivia.trivia()

      let module' =
        recover val
          NamedRule("Module",
            Conj([
              Bind(tr, trivia_trivia)
              Bind(ds, Star(docstring()))
              // Disj([
              //   Neg(Disj([using(); typedef(); trivia_trivia],
              //     {(r, c, b) =>
              //       (ast.ErrorSection(_Build.info(r), c,
              //         ErrorMsg.expected_using_or_type_def()), b)
              //     }))
              //   Conj([
              //     Bind(us, Star(using()))
              //     Bind(typedefs, Star(typedef()))
              //   ])
              // ])
              trivia_trivia
            ]),
            {(r, c, b) =>
              let trivia': ast.Trivia =
                try
                  b(tr)?._2(0)? as ast.Trivia
                else
                  return (ast.ErrorSection(_Build.info(r), c,
                    ErrorMsg.internal_ast_node_not_bound("Trivia")), b)
                end

              let docstring': (ast.Docstring | ast.ErrorSection | None) =
                try
                  (_, let values: ast.NodeSeq[ast.Node]) = b(ds)?
                  if values.size() == 1 then
                    values(0)? as ast.Docstring
                  elseif values.size() > 1 then
                    ast.ErrorSection(_Build.info(r), [],
                      ErrorMsg.module_docstring_multiple())
                  end
                end

              let m = ast.Module(r.data.locator(), _Build.info(r), c, trivia',
                docstring', recover val Array[ast.Node] end,
                recover val Array[ast.Node] end)
              (m, b)
            })
        end
      _module = module'
      module'
    end

  fun ref docstring(): NamedRule =>
    match _docstring
    | let r: NamedRule => r
    else
      let trivia_trivia = _trivia.trivia()
      let literal_string = _literal.string()

      let t = Variable
      let s = Variable
      let docstring' =
        recover val
          NamedRule("DocString",
            Conj([
              Bind(t, trivia_trivia)
              Bind(s, literal_string)
            ]),
            {(r, c, b) =>
              let t': ast.Trivia =
                try
                  b(t)?._2(0)? as ast.Trivia
                else
                  return (ast.ErrorSection(_Build.info(r), c,
                    ErrorMsg.internal_ast_node_not_bound("Trivia")), b)
                end

              let s': ast.LiteralString =
                try
                  b(s)?._2(0)? as ast.LiteralString
                else
                  return (ast.ErrorSection(_Build.info(r), c,
                    ErrorMsg.internal_ast_node_not_bound("LiteralString")), b)
                end

              (ast.Docstring(_Build.info(r), c, t', s'), b)
            })
        end
      _docstring = docstring'
      docstring'
    end
