use "kiuatan"
use "../parser"
use "../types"

class val AstLiteralBool[CH: ((U8 | U16) & UnsignedInteger[CH])] is (
    AstNode[CH]
    & AstNodeTyped[CH, AstLiteralBool[CH]]
    & AstNodeValue[Bool]
  )

  let _src_info: SrcInfo[CH]
  let _ast_type: AstType[CH]
  let _value: Bool

  new val create(context: ParserContext[CH], src_info': SrcInfo[CH],
    value': Bool)
  =>
    _src_info = src_info'
    _ast_type = context.builtin().bool()
    _value = value'

  fun src_info(): SrcInfo[CH] => _src_info

  fun eq(other: box->AstNode[CH]): Bool =>
    match other
    | let lb: box->AstLiteralBool[CH] =>
      (this.start() == lb.start()) and (this.next() == lb.next())
        and (this.value() == lb.value())
    else
      false
    end

  fun ne(other: box->AstNode[CH]): Bool => not this.eq(other)

  fun string(): String iso^ =>
    "<LIT: " + ast_type().string() + " = " + _value.string() + ">"

  fun ast_type(): AstType[CH] => _ast_type

  fun val with_ast_type(ast_type': AstType[CH]): AstLiteralBool[CH] => this

  fun value(): Bool => _value


class val AstLiteralInteger[CH] is (
    AstNode[CH] & AstNodeTyped[CH, AstLiteralInteger[CH]]
  )

  let _src_info: SrcInfo[CH]
  let _ast_type: (AstType[CH] | None)
  let _bcd_value: ReadSeq[U8]

  new create(src_info': SrcInfo[CH], bcd_value: ReadSeq[U8] val) =>
    _src_info = src_info'
    _ast_type = None
    _bcd_value = bcd_value

  new _with_ast_type(orig: AstLiteralInteger[CH], ast_type': AstType[CH]) =>
    _src_info = orig._src_info
    _ast_type = ast_type'
    _bcd_value = orig._bcd_value

  fun src_info(): SrcInfo[CH] => _src_info

  fun eq(other: box->AstNode[CH]): Bool =>
    match other
    | let li: box->AstLiteralInteger[CH] =>
      if (this.start() == li.start()) and (this.next() == li.next()) then
        let size_this = this._bcd_value.size()
        let size_other = li._bcd_value.size()
        if size_this != size_other then return false end
        if size_this == 0 then return true end
        try
          var i: USize = 0
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

  fun ne(other: box->AstNode[CH]): Bool => not this.eq(other)

  fun string(): String iso^ =>
    let type_name =
      match _ast_type
      | let t: AstType[CH] =>
        t.string()
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

  fun ast_type(): (AstType[CH] | None) => _ast_type

  fun val with_ast_type(ast_type': AstType[CH]): AstLiteralInteger[CH] =>
    recover
      AstLiteralInteger[CH]._with_ast_type(this, ast_type')
    end
