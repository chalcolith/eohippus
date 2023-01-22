use "itertools"

use json = "../json"
use parser = "../parser"
use types = "../types"

class val TypeParams is (Node & NodeWithType[TypeParams] & NodeWithChildren)
  let _src_info: SrcInfo
  let _ast_type: (types.AstType | None)
  let _children: NodeSeq

  let _lhs: Node
  let _param_seq: NodeSeq
  let _params: NodeSeq

  new val create(src_info': SrcInfo, children': NodeSeq,
    lhs': Node, param_seq': NodeSeq)
  =>
    _src_info = src_info'
    _ast_type = None
    _children = children'
    _lhs = lhs'
    _param_seq = param_seq'
    _params =
      recover val
        Array[Node].>concat(Iter[Node](_param_seq.values())
          .filter({(n) =>
            match n
            | let _: Trivia => false
            | let _: Token => false
            else true end
          }))
      end

  new val _with_ast_type(orig: TypeParams, ast_type': types.AstType) =>
    _src_info = orig._src_info
    _ast_type = ast_type'
    _children = orig._children
    _lhs = orig._lhs
    _param_seq = orig._param_seq
    _params = orig._params

  fun src_info(): SrcInfo => _src_info

  fun info(): json.Item val =>
    recover
      let items = Array[(String, json.Item)]
      items.push(("node", "TypeParams"))
      items.push(("lhs", _lhs.info()))
      let params' =
        recover val
          Array[json.Item].>concat(
            Iter[Node](_params.values())
              .map[json.Item]({(p) => p.info()}))
        end
      if params'.size() > 0 then
        items.push(("params", json.Sequence(params')))
      end
      json.Object(items)
    end

  fun ast_type(): (types.AstType | None) => _ast_type

  fun val with_ast_type(ast_type': types.AstType): TypeParams =>
    TypeParams._with_ast_type(this, ast_type')

  fun children(): NodeSeq => _children

  fun lhs(): Node => _lhs

  fun params(): NodeSeq => _params
