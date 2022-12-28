use "itertools"

use json = "../json"
use types = "../types"

class val If is (Node & NodeWithType[If] & NodeWithChildren)
  let _src_info: SrcInfo
  let _ast_type: (types.AstType | None)
  let _children: NodeSeq

  let _conditions: NodeSeq[IfCondition]
  let _else_block: (Node | None)

  new val create(src_info': SrcInfo, children': NodeSeq,
    conditions': NodeSeq[IfCondition], else_block': (Node | None))
  =>
    _src_info = src_info'
    _ast_type = None
    _children = children'
    _conditions = conditions'
    _else_block = else_block'

  new val _with_ast_type(orig: If, ast_type': types.AstType) =>
    _src_info = orig._src_info
    _ast_type = ast_type'
    _children = orig._children
    _conditions = orig._conditions
    _else_block = orig._else_block

  fun src_info(): SrcInfo => _src_info

  fun info(): json.Item iso^ =>
    recover
      let conds =
        json.Sequence(
          Array[json.Item].>concat(
            Iter[IfCondition](_conditions.values())
              .map[json.Item]({(cond) => cond.info()}))
        )
      let properties =
        [as (String, json.Item):
          ("node", "If")
          ("conditions", conds)
        ]
      match _else_block
      | let n: Node =>
        properties.push(("else_block", n.info()))
      end

      json.Object(properties)
    end

  fun ast_type(): (types.AstType | None) => _ast_type
  fun val with_ast_type(ast_type': types.AstType): If =>
    If._with_ast_type(this, ast_type')
  fun children(): NodeSeq => _children
  fun conditions(): NodeSeq[IfCondition] => _conditions
  fun else_block(): (Node | None) => _else_block

class val IfCondition is (Node & NodeWithType[IfCondition] & NodeWithChildren)
  let _src_info: SrcInfo
  let _ast_type: (types.AstType | None)
  let _children: NodeSeq

  let _if_true: Node
  let _then_block: Node

  new val create(src_info': SrcInfo, children': NodeSeq,
    if_true': Node, then_block': Node) =>
    _src_info = src_info'
    _ast_type = None
    _children = children'
    _if_true = if_true'
    _then_block = then_block'

  new val _with_ast_type(orig: IfCondition, ast_type': types.AstType) =>
    _src_info = orig._src_info
    _ast_type = ast_type'
    _children = orig._children
    _if_true = orig._if_true
    _then_block = orig._then_block

  fun src_info(): SrcInfo => _src_info

  fun info(): json.Item iso^ =>
    recover
      json.Object([
        ("node", "IfCondition")
        ("condition", _if_true.info())
        ("then", _then_block.info())
      ])
    end

  fun ast_type(): (types.AstType | None) => _ast_type
  fun val with_ast_type(ast_type': types.AstType): IfCondition =>
    IfCondition._with_ast_type(this, ast_type')
  fun children(): NodeSeq => _children
  fun if_true(): Node => _if_true
  fun then_block(): Node => _then_block
