
class TypeBuilder
  let _context: Context

  var _type: (NamedRule | None) = None

  new create(context: Context) =>
    _context = context

  fun ref type_rule(): NamedRule =>
    match _type
    | let r: NamedRule => r
    else
      let type' =
        recover val
          NamedRule("Type_Type", None) // TODO
        end
      _type = type'
      type'
    end
