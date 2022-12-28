use json = "../json"
use parser = "../parser"

class val TypedefPrimitive is (Node & NodeWithDocstring)
  let _src_info: SrcInfo
  let _docstring: NodeSeq[Docstring]
  let _identifier: Identifier

  new val create(src_info': SrcInfo, docstring': NodeSeq[Docstring],
    identifier': Identifier)
  =>
    _src_info = src_info'
    _docstring = docstring'
    _identifier = identifier'

  fun src_info(): SrcInfo => _src_info

  fun has_error(): Bool => false

  fun info(): json.Item iso^ =>
    recover
      json.Object([
        ("node", "TypedefPrimitive")
        ("name", _identifier.info())
      ])
    end

  fun docstring(): NodeSeq[Docstring] => _docstring

  fun identifier(): Identifier => _identifier
