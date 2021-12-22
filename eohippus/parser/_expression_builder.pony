use ast = "../ast"

primitive _Letters
  fun apply(): String =>
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

primitive _Digits
  fun apply(): String =>
    "0123456789"

class _ExpressionBuilder
  let _context: Context

  var _identifier: (NamedRule | None) = None

  new create(context: Context) =>
    _context = context

  fun ref identifier(): NamedRule =>
    match _identifier
    | let r: NamedRule => r
    else
      let identifier' =
        recover val
          NamedRule("Identifier",
            Disj([
              Conj([
                Single(_Letters())
                Star(Single(_Letters() + _Digits() + "_'"))
              ])
              Conj([
                Single("_")
                Star(Single(_Letters() + _Digits() + "_'"))
              ])
            ]),
            {(r, _, b) => (ast.Identifier(_Build.info(r)), b) })
        end
      _identifier = identifier'
      identifier'
    end
