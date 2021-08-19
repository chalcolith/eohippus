use parser = "../parser"
use types = "../types"

class val LiteralBool is (Node & NodeTyped[LiteralBool] & NodeValue[Bool])
  let _src_info: SrcInfo
  let _ast_type: types.AstType
  let _value: Bool

  new val create(context: parser.Context, src_info': SrcInfo, value': Bool) =>
    _src_info = src_info'
    _ast_type = context.builtin().bool()
    _value = value'

  fun src_info(): SrcInfo => _src_info

  fun eq(other: box->Node): Bool =>
    match other
    | let lb: box->LiteralBool =>
      (this.start() == lb.start()) and (this.next() == lb.next())
        and (this.value() == lb.value())
    else
      false
    end

  fun ne(other: box->Node): Bool => not this.eq(other)

  fun string(): String iso^ =>
    "<LIT: " + ast_type().string() + " = " + _value.string() + ">"

  fun ast_type(): types.AstType => _ast_type

  fun val with_ast_type(ast_type': types.AstType): LiteralBool => this

  fun value(): Bool => _value


class val LiteralInteger is (Node & NodeTyped[LiteralInteger])
  let _src_info: SrcInfo
  let _ast_type: (types.AstType | None)
  let _bcd_value: ReadSeq[U8]

  new create(src_info': SrcInfo, bcd_value: ReadSeq[U8] val) =>
    _src_info = src_info'
    _ast_type = None
    _bcd_value = bcd_value

  new _with_ast_type(orig: LiteralInteger, ast_type': types.AstType) =>
    _src_info = orig._src_info
    _ast_type = ast_type'
    _bcd_value = orig._bcd_value

  fun src_info(): SrcInfo => _src_info

  fun eq(other: box->Node): Bool =>
    match other
    | let li: box->LiteralInteger =>
      if (this.start() == li.start()) and (this.next() == li.next()) then
        let size_this = this._bcd_value.size()
        let size_other = li._bcd_value.size()
        if size_this != size_other then return false end
        if size_this == 0 then return true end
        try
          var i = USize(0)
          while i < size_this do
            if this._bcd_value(i)? != li._bcd_value(i)? then
              return false
            end
            i = i + 1
          end
          return true
        end
      end
    end
    false

  fun ne(other: box->Node): Bool => not this.eq(other)

  fun string(): String iso^ =>
    let type_name =
      match _ast_type
      | let type': types.AstType =>
        type'.string()
      else
        "?LiteralInteger?"
      end
    recover
      let str = "<LIT: " + type_name + " = "
      for d in _bcd_value.values() do
        str.push('0' + d)
      end
      str + ">"
    end

  fun ast_type(): (types.AstType | None) => _ast_type

  fun val with_ast_type(ast_type': types.AstType): LiteralInteger =>
    recover
      LiteralInteger._with_ast_type(this, ast_type')
    end
