use json = "../json"
use ".."

class val Identifier is (Node & NodeWithName & NodeWithTrivia)
  let _src_info: SrcInfo
  let _body: Span
  let _post_trivia: Trivia
  let _name: String

  new val create(src_info': SrcInfo, post_trivia': Trivia, name': String) =>
    _src_info = src_info'
    _body = Span(SrcInfo(src_info'.locator(), src_info'.start(),
      post_trivia'.src_info().start()))
    _post_trivia = post_trivia'
    _name = name'

  fun src_info(): SrcInfo => _src_info
  fun has_error(): Bool => false
  fun info(): json.Item iso^ =>
    recover
      json.Object([
        ("node", "Identifier")
        ("name", _name)
      ])
    end
  fun body(): Span => _body
  fun post_trivia(): Trivia => _post_trivia

  fun name(): String => _name
