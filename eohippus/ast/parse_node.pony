use json = "../json"
use parser = "../parser"

primitive ParseNode
  fun apply(locator: parser.Locator, obj: json.Object): (Node | String) =>
    let name =
      match try obj("name")? end
      | let str: String box =>
        str
      else
        return "node.name must be a string"
      end
    let src_info =
      match try obj("src_info")? end
      | let src_info_obj: json.Object box =>
        let line' =
          match try src_info_obj("line")? end
          | let n: I128 =>
            n
          else
            return "src_info.line must be an integer"
          end
        let column' =
          match try src_info_obj("column")? end
          | let n: I128 =>
            n
          else
            return "src_info.column must be an integer"
          end
        let next_line' =
          match try src_info_obj("next_line")? end
          | let n: I128 =>
            n
          else
            return "src_info.next_line must be an integer"
          end
        let next_column' =
          match try src_info_obj("next_column")? end
          | let n: I128 =>
            n
          else
            return "src_info.next_column must be an integer"
          end
        SrcInfo(locator where
          line' = USize.from[I128](line'),
          column' = USize.from[I128](column'),
          next_line' = USize.from[I128](next_line'),
          next_column' = USize.from[I128](next_column'))
      else
        SrcInfo(locator)
      end
    let scope_index =
      match try obj("scope")? end
      | let index: I128 =>
        USize.from[I128](index)
      end

    let children': Array[Node] trn = Array[Node]
    match try obj("children")? end
    | let children_seq: json.Sequence =>
      for child_item in children_seq.values() do
        match child_item
        | let child_obj: json.Object =>
          match ParseNode(locator, child_obj)
          | let n: Node =>
            children'.push(n)
          | let err: String =>
            return err
          end
        else
          return "node.children should be a sequence of objects"
        end
      end
    end
    let children: Array[Node] val = consume children'

    let annotation =
      match try obj("annotation")? end
      | let int: I128 =>
        match try children(USize.from[I128](int))? end
        | let annotation': NodeWith[Annotation] =>
          annotation'
        else
          return "annotation must refer to an Annotation"
        end
      | None =>
        None
      else
        return "annotation must refer to an Annotation"
      end

    let doc_strings =
      match _get_seq_with[DocString](
        obj,
        children,
        "doc_strings",
        "doc_strings must refer to DocStrings",
        false)
      | let seq: NodeSeqWith[DocString] =>
        seq
      | let err: String =>
        return err
      end
    let pre_trivia =
      match _get_seq_with[Trivia](
        obj,
        children,
        "pre_trivia",
        "pre_trivia must refer to Trivias",
        false)
      | let seq: NodeSeqWith[Trivia] =>
        seq
      | let err: String =>
        return err
      end
    let post_trivia =
      match _get_seq_with[Trivia](
        obj,
        children,
        "post_trivia",
        "post_trivia must refer to Trivias",
        false)
      | let seq: NodeSeqWith[Trivia] =>
        seq
      | let err: String =>
        return err
      end

    let ctor: (_NodeConstructor | None) =
      match name
      | "Annotation" =>
        ParseNode~_ctor[Annotation](ParseAnnotation~apply(obj, children))
      | "CallArgs" =>
        ParseNode~_ctor[CallArgs](ParseCallArgs~apply(obj, children))
      | "DocString" =>
        ParseNode~_ctor[DocString](ParseDocString~apply(obj, children))
      | "ErrorSection" =>
        ParseNode~_ctor[ErrorSection](ParseErrorSection~apply(obj, children))
      | "ExpArray" =>
        ParseNode~_ctor[Expression](ParseExpArray~apply(obj, children))
      | "ExpAtom" =>
        ParseNode~_ctor[Expression](ParseExpAtom~apply(obj, children))
      | "ExpCall" =>
        ParseNode~_ctor[Expression](ParseExpCall~apply(obj, children))
      | "ExpConsume" =>
        ParseNode~_ctor[Expression](ParseExpConsume~apply(obj, children))
      | "ExpDecl" =>
        ParseNode~_ctor[Expression](ParseExpDecl~apply(obj, children))
      | "ExpFfi" =>
        ParseNode~_ctor[Expression](ParseExpFfi~apply(obj, children))
      | "ExpFor" =>
        ParseNode~_ctor[Expression](ParseExpFor~apply(obj, children))
      | "ExpGeneric" =>
        ParseNode~_ctor[Expression](ParseExpGeneric~apply(obj, children))
      | "ExpHash" =>
        ParseNode~_ctor[Expression](ParseExpHash~apply(obj, children))
      | "ExpIf" =>
        ParseNode~_ctor[Expression](ParseExpIf~apply(obj, children))
      | "IfCondition" =>
        ParseNode~_ctor[IfCondition](ParseIfCondition~apply(obj, children))
      | "ExpJump" =>
        ParseNode~_ctor[Expression](ParseExpJump~apply(obj, children))
      | "ExpLambda" =>
        ParseNode~_ctor[Expression](ParseExpLambda~apply(obj, children))
      | "ExpMatch" =>
        ParseNode~_ctor[Expression](ParseExpMatch~apply(obj, children))
      | "MatchCase" =>
        ParseNode~_ctor[MatchCase](ParseMatchCase~apply(obj, children))
      | "ExpObject" =>
        ParseNode~_ctor[Expression](ParseExpObject~apply(obj, children))
      | "ExpOperation" =>
        ParseNode~_ctor[Expression](ParseExpOperation~apply(obj, children))
      | "ExpRecover" =>
        ParseNode~_ctor[Expression](ParseExpRecover~apply(obj, children))
      | "ExpRepeat" =>
        ParseNode~_ctor[Expression](ParseExpRepeat~apply(obj, children))
      | "ExpSequence" =>
        ParseNode~_ctor[Expression](ParseExpSequence~apply(obj, children))
      | "ExpTry" =>
        ParseNode~_ctor[Expression](ParseExpTry~apply(obj, children))
      | "ExpTuple" =>
        ParseNode~_ctor[Expression](ParseExpTuple~apply(obj, children))
      | "ExpWhile" =>
        ParseNode~_ctor[Expression](ParseExpWhile~apply(obj, children))
      | "ExpWith" =>
        ParseNode~_ctor[Expression](ParseExpWith~apply(obj, children))
      | "WithElement" =>
        ParseNode~_ctor[WithElement](ParseWithElement~apply(obj, children))
      | "Identifier" =>
        ParseNode~_ctor[Identifier](ParseIdentifier~apply(obj, children))
      | "Keyword" =>
        ParseNode~_ctor[Keyword](ParseKeyword~apply(obj, children))
      | "LiteralBool" =>
        ParseNode~_ctor[LiteralBool](ParseLiteralBool~apply(obj, children))
      | "LiteralChar" =>
        ParseNode~_ctor[LiteralChar](ParseLiteralChar~apply(obj, children))
      | "LiteralFloat" =>
        ParseNode~_ctor[LiteralFloat](ParseLiteralFloat~apply(obj, children))
      | "LiteralInteger" =>
        ParseNode~_ctor[LiteralInteger](ParseLiteralInteger~apply(
          obj, children))
      | "LiteralString" =>
        ParseNode~_ctor[LiteralString](ParseLiteralString~apply(obj, children))
      | "MethodParam" =>
        ParseNode~_ctor[MethodParam](ParseMethodParam~apply(obj, children))
      | "MethodParams" =>
        ParseNode~_ctor[MethodParams](ParseMethodParams~apply(obj, children))
      | "Span" =>
        ParseNode~_ctor[Span](ParseSpan~apply(obj, children))
      | "SrcFile" =>
        ParseNode~_ctor[SrcFile](ParseSrcFile~apply(obj, children))
      | "Token" =>
        ParseNode~_ctor[Token](ParseToken~apply(obj, children))
      | "Trivia" =>
        ParseNode~_ctor[Trivia](ParseTrivia~apply(obj, children))
      | "TuplePattern" =>
        ParseNode~_ctor[TuplePattern](ParseTuplePattern~apply(obj, children))
      | "TypeArgs" =>
        ParseNode~_ctor[TypeArgs](ParseTypeArgs~apply(obj, children))
      | "TypeArrow" =>
        ParseNode~_ctor[TypeType](ParseTypeArrow~apply(obj, children))
      | "TypeAtom" =>
        ParseNode~_ctor[TypeType](ParseTypeAtom~apply(obj, children))
      | "TypeInfix" =>
        ParseNode~_ctor[TypeType](ParseTypeInfix~apply(obj, children))
      | "TypeLambda" =>
        ParseNode~_ctor[TypeType](ParseTypeLambda~apply(obj, children))
      | "TypeNominal" =>
        ParseNode~_ctor[TypeType](ParseTypeNominal~apply(obj, children))
      | "TypeParams" =>
        ParseNode~_ctor[TypeParams](ParseTypeParams~apply(obj, children))
      | "TypeParam" =>
        ParseNode~_ctor[TypeParam](ParseTypeParam~apply(obj, children))
      | "TypeTuple" =>
        ParseNode~_ctor[TypeType](ParseTypeTuple~apply(obj, children))
      | "TypedefAlias" =>
        ParseNode~_ctor[Typedef](ParseTypedefAlias~apply(obj, children))
      | "TypedefClass" =>
        ParseNode~_ctor[Typedef](ParseTypedefClass~apply(obj, children))
      | "TypedefField" =>
        ParseNode~_ctor[TypedefField](ParseTypedefField~apply(obj, children))
      | "TypedefMembers" =>
        ParseNode~_ctor[TypedefMembers](ParseTypedefMembers~apply(
          obj, children))
      | "TypedefMethod" =>
        ParseNode~_ctor[TypedefMethod](ParseTypedefMethod~apply(obj, children))
      | "TypedefPrimitive" =>
        ParseNode~_ctor[Typedef](ParseTypedefPrimitive~apply(obj, children))
      | "UsingFFI" =>
        ParseNode~_ctor[Using](ParseUsingFFI~apply(obj, children))
      | "UsingPony" =>
        ParseNode~_ctor[Using](ParseUsingPony~apply(obj, children))
      end
    match ctor
    | let ctor': _NodeConstructor =>
      ctor'(
        src_info,
        children,
        annotation,
        doc_strings,
        pre_trivia,
        post_trivia,
        scope_index)
    else
      "unknown node data type " + name
    end

  fun _get_child(
    obj: json.Object,
    children: NodeSeq,
    key: String,
    help: String,
    mandatory: Bool = true)
    : (Node | String | None)
  =>
    match try obj(key)? end
    | let i: I128 =>
      match try children(USize.from[I128](i))? end
      | let node: Node =>
        node
      else
        help
      end
    else
      if mandatory then
        help
      end
    end

  fun _get_child_with[D: NodeData val](
    obj: json.Object,
    children: NodeSeq,
    key: String,
    help: String,
    mandatory: Bool = true)
    : (NodeWith[D] | String | None)
  =>
    match try obj(key)? end
    | let i: I128 =>
      match try children(USize.from[I128](i))? end
      | let node: NodeWith[D] =>
        node
      | let node': Node =>
        help + "; got a " + node'.name()
      else
        help
      end
    | let item: json.Item =>
      help
    else
      if mandatory then
        help
      end
    end

  fun _get_seq_with[D: NodeData val](
    obj: json.Object,
    children: NodeSeq,
    key: String,
    help: String,
    mandatory: Bool = true)
    : (NodeSeqWith[D] | String)
  =>
    match try obj(key)? end
    | let seq: json.Sequence =>
      let nodes: Array[NodeWith[D]] trn = Array[NodeWith[D]]
      for item in seq.values() do
        match item
        | let n: I128 =>
          try
            nodes.push(children(USize.from[I128](n))? as NodeWith[D])
          else
            return help
          end
        else
          return help
        end
      end
      consume nodes
    | let item: json.Item =>
      help
    else
      if mandatory then
        help
      else
        []
      end
    end

  fun _ctor[D: NodeData val](
    ctor: {(): (D | String)} box,
    src_info: SrcInfo,
    children: NodeSeq,
    annotation: (NodeWith[Annotation] | None),
    doc_strings: NodeSeqWith[DocString],
    pre_trivia: NodeSeqWith[Trivia],
    post_trivia: NodeSeqWith[Trivia],
    scope_index: (USize | None))
    : (Node | String)
  =>
    let data =
      match ctor()
      | let data': D =>
        data'
      | let err: String =>
        return err
      end

    NodeWith[D](
      src_info,
      children,
      data,
      annotation,
      doc_strings,
      pre_trivia,
      post_trivia,
      None,
      scope_index)

type _NodeConstructor is
  {(SrcInfo,
    NodeSeq,
    (NodeWith[Annotation] | None),
    NodeSeqWith[DocString],
    NodeSeqWith[Trivia],
    NodeSeqWith[Trivia],
    (USize | None))
    : (Node | String)} box
