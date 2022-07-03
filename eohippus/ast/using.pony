use parser = "../parser"
use ".."

class val UsingPony is (Node & NodeParent & NodeTrivia)
  let _src_info: SrcInfo
  let _children: NodeSeq
  let _pre_trivia: Trivia
  let _post_trivia: Trivia
  let _identifier: (Identifier | None)
  let _path: LiteralString
  let _def_flag: Bool
  let _def_id: (Identifier | None)

  new val create(src_info': SrcInfo, children': NodeSeq,
    pre_trivia': Trivia, post_trivia': Trivia,
    identifier': (Identifier | None), path': LiteralString,
    def_flag': Bool, def_id': (Identifier | None))
  =>
    _src_info = src_info'
    _children = children'
    _pre_trivia = pre_trivia'
    _post_trivia = post_trivia'
    _identifier = identifier'
    _path = path'
    _def_flag = def_flag'
    _def_id = def_id'

  fun src_info(): SrcInfo => _src_info
  fun get_string(indent: String): String =>
    let def_str =
      match _def_id
      | let di: Identifier =>
        if not _def_flag then
          "not " + StringUtil.escape(di.name())
        else
          StringUtil.escape(di.name())
        end
      else
        ""
      end

    match _identifier
    | let id: Identifier =>
      indent + "<USE " + StringUtil.escape(id.name()) + " = \""
        + StringUtil.escape(_path.value()) + "\"" + def_str + ">"
    else
      indent + "<USE \"" + StringUtil.escape(_path.value()) + "\"" + def_str
        + ">"
    end

  fun children(): NodeSeq => _children
  fun pre_trivia(): Trivia => _pre_trivia
  fun post_trivia(): Trivia => _post_trivia

  fun identifier(): (Identifier | None) => _identifier
  fun path(): LiteralString => _path
  fun def_flag(): Bool => _def_flag
  fun def_id(): (Identifier | None) => _def_id
