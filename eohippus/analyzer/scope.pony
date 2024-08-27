use "collections"

use ast = "../ast"
use json = "../json"

primitive PackageScope
primitive FileScope
primitive ClassScope
primitive MethodScope
primitive BlockScope
primitive QualifierScope

type ScopeKind is
  ( PackageScope
  | FileScope
  | ClassScope
  | MethodScope
  | BlockScope
  | QualifierScope )

type SrcRange is (USize, USize, USize, USize)

type ScopeItem is (ast.Node, String, String)

class val Scope
  let kind: ScopeKind
  let name: String
  let canonical_path: String
  var range: SrcRange
  var parent: (Scope box | None)
  let imports: Array[ScopeItem] = imports.create()
  let definitions: Map[String, Array[ScopeItem]] = definitions.create()
  let children: Array[Scope box] = children.create()

  new create(
    kind': ScopeKind,
    name': String,
    canonical_path': String,
    range': SrcRange,
    parent': (Scope box | None) = None)
  =>
    kind = kind'
    name = name'
    canonical_path = canonical_path'
    range = range'
    parent = parent'

  fun get_child_range(): SrcRange =>
    try
      let first = children(0)?
      let last = children(children.size() - 1)?
      (first.range._1, first.range._2, last.range._3, last.range._4)
    else
      (0, 0, 0, 0)
    end

  fun ref add_import(node: ast.Node, identifier: String, path: String) =>
    imports.push((node, identifier, path))

  fun ref add_definition(
    node: ast.Node,
    identifier: String,
    docs: (ast.NodeSeqWith[ast.DocString] | String))
  =>
    let arr =
      try
        definitions(identifier)?
      else
        let arr' = Array[ScopeItem]
        definitions(identifier) = arr'
        arr'
      end
    match docs
    | let seq: ast.NodeSeqWith[ast.DocString] =>
      arr.push((node, identifier, _get_docstring(seq)))
    | let str: String =>
      arr.push((node, identifier, str))
    end

  fun ref add_child(child: Scope box) =>
    children.push(child)

  fun _get_docstring(docs: ast.NodeSeqWith[ast.DocString]): String =>
    if docs.size() > 0 then
      let str: String trn = String
      for ds in docs.values() do
        if str.size() > 0 then
          str.append("\n\n")
        end
        str.append(ds.data().string.data().value())
      end
      consume str
    else
      ""
    end

  fun get_json(node_indices: MapIs[ast.Node, USize] val): json.Object =>
    let props = Array[(String, json.Item)]
    let kind_string =
      match kind
      | PackageScope =>
        "PackageScope"
      | FileScope =>
        "FileScope"
      | ClassScope =>
        "ClassScope"
      | MethodScope =>
        "MethodScope"
      | BlockScope =>
        "BlockScope"
      | QualifierScope =>
        "QualifierScope"
      end
    props.push(("kind", kind_string))
    props.push(("name", name))
    if (kind is PackageScope) or (kind is FileScope) then
      props.push(("canonical_path", canonical_path))
    end
    props.push(
      ( "range",
        json.Sequence(
          [ as I128:
            I128.from[USize](range._1)
            I128.from[USize](range._2)
            I128.from[USize](range._3)
            I128.from[USize](range._4)
          ])) )
    if imports.size() > 0 then
      let import_items = Array[json.Item]
      for (node, identifier, path) in imports.values() do
        let index = try node_indices(node)? else USize.max_value() end
        import_items.push(json.Object(
          [ as (String, json.Item):
            ("node", I128.from[USize](index))
            ("identifier", identifier)
            ("path", path)
          ]))
      end
      props.push(("imports", json.Sequence(import_items)))
    end
    if definitions.size() > 0 then
      let def_items = Array[json.Item]
      for def_array in definitions.values() do
        for (node, identifier, doc_string) in def_array.values() do
          let index = try node_indices(node)? else USize.max_value() end
          def_items.push(json.Object(
            [ as (String, json.Item):
              ("node", I128.from[USize](index))
              ("identifier", identifier)
              ("doc_string", doc_string) ]))
        end
      end
      props.push(("definitions", json.Sequence(def_items)))
    end
    if children.size() > 0 then
      let children_items = Array[json.Item]
      for child in children.values() do
        children_items.push(child.get_json(node_indices))
      end
      props.push(("children", json.Sequence(children_items)))
    end
    json.Object(consume props)

primitive ParseScopeJson
  fun apply(
    nodes: Map[USize, ast.Node] val,
    scope_item: json.Item,
    parent: (Scope ref | None))
    : (Scope ref | String)
  =>
    match scope_item
    | let scope_obj: json.Object =>
      let kind =
        match try scope_obj("kind")? end
        | "PackageScope" =>
          PackageScope
        | "FileScope" =>
          FileScope
        | "ClassScope" =>
          ClassScope
        | "MethodScope" =>
          MethodScope
        | "BlockScope" =>
          BlockScope
        | "QualifierScope" =>
          QualifierScope
        else
          return "invalid scope kind"
        end
      let name =
        match try scope_obj("name")? end
        | let str: String box =>
          str
        else
          return "scope.name must be a string"
        end
      let canonical_path =
        match try scope_obj("canonical_path")? end
        | let str: String box =>
          str.clone()
        else
          match parent
          | let parent': Scope box =>
            parent'.canonical_path
          else
            ""
          end
        end
      let range =
        match try scope_obj("range")? end
        | let seq: json.Sequence box =>
          match try (seq(0)?, seq(1)?, seq(2)?, seq(3)?) end
          | (let l: I128, let c: I128, let nl: I128, let nc: I128) =>
            ( USize.from[I128](l),
              USize.from[I128](c),
              USize.from[I128](nl),
              USize.from[I128](nc) )
          else
            return "scope.range must be a sequence of integers"
          end
        else
          return "scope.range must be a sequence of integers"
        end

      let scope = Scope(kind, name.clone(), canonical_path, range, parent)

      match try scope_obj("imports")? end
      | let seq: json.Sequence =>
        for item in seq.values() do
          match item
          | let obj: json.Object =>
            try
              let index = USize.from[I128](obj("node")? as I128)
              let identifier = obj("identifier")? as String box
              let path = obj("path")? as String box
              match try nodes(index)? end
              | let node: ast.Node =>
                scope.add_import(node, identifier.clone(), path.clone())
              else
                return "unknown node index " + index.string()
              end
            else
              return "scope.imports.N must be an object"
            end
          end
        end
      end
      match try scope_obj("definitions")? end
      | let seq: json.Sequence =>
        for item in seq.values() do
          match item
          | let obj: json.Object =>
            try
              let index = USize.from[I128](obj("node")? as I128)
              let identifier = obj("identifier")? as String box
              let doc_string = obj("doc_string")? as String box
              match try nodes(index)? end
              | let node: ast.Node =>
                scope.add_definition(
                  node, identifier.clone(), doc_string.clone())
              else
                return "unknown node index " + index.string()
              end
            else
              return "scope.definitions.N must be an object"
            end
          end
        end
      end
      match try scope_obj("children")? end
      | let seq: json.Sequence =>
        for item in seq.values() do
          match ParseScopeJson(nodes, item, scope)
          | let child: Scope ref =>
            scope.add_child(child)
          | let err: String =>
            return err
          end
        end
      end

      scope
    else
      "scope must be a JSON object"
    end
