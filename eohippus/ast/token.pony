
primitive TokenDoubleQuote
primitive TokenTripleDoubleQuote
primitive TokenSemicolon

type TokenKind is (
  TokenDoubleQuote |
  TokenTripleDoubleQuote |
  TokenSemicolon )

class val Token is Node
  let _src_info: SrcInfo
  let _kind: TokenKind

  new val create(src_info': SrcInfo, kind': TokenKind) =>
    _src_info = src_info'
    _kind = kind'

  fun src_info(): SrcInfo => _src_info
  fun has_error(): Bool => false
  fun get_string(indent: String): String =>
    indent + "<TOKEN: "
      + match _kind
        | TokenDoubleQuote => "\\\""
        | TokenTripleDoubleQuote => "\\\"\\\"\\\""
        | TokenSemicolon => ";"
        end
      + ">"

  fun kind(): TokenKind => _kind
