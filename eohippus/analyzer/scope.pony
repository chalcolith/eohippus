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

type ScopeItem is (String, USize, USize, USize, USize, String)

class Scope
  let kind: ScopeKind
  let name: String
  var parent: (Scope | None)
  let imports: Array[(String, String)] = imports.create()
  let definitions: Array[ScopeItem] = definitions.create()
  let contents: Array[ScopeItem] = contents.create()
  let children: Array[Scope] = children.create()

  new create(
    kind': ScopeKind,
    name': String,
    parent': (Scope | None) = None)
  =>
    kind = kind'
    name = name'
    parent = parent'

    match parent
    | let parent_scope: Scope =>
      parent_scope.children.push(this)
    end

  fun ref add_definition(
    identifier: String,
    si: ast.SrcInfo,
    docs: ast.NodeSeqWith[ast.DocString])
  =>
    match (si.line, si.column, si.next_line, si.next_column)
    | (let l: USize, let c: USize, let nl: USize, let nc: USize) =>
      definitions.push((identifier, l, c, nl, nc, _get_docstring(docs)))
    end

  fun ref add_content(
    identifier: String,
    si: ast.SrcInfo,
    docs: ast.NodeSeqWith[ast.DocString])
  =>
    match (si.line, si.column, si.next_line, si.next_column)
    | (let l: USize, let c: USize, let nl: USize, let nc: USize) =>
      contents.push((identifier, l, c, nl, nc, _get_docstring(docs)))
    end

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

  fun get_json(): json.Object =>
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
    if imports.size() > 0 then
      let import_items = Array[json.Item]
      for (ident, path) in imports.values() do
        import_items.push(json.Object(
          [ as (String, json.Item): ("identifier", ident); ("path", path) ]))
      end
      props.push(("imports", json.Sequence(import_items)))
    end
    if definitions.size() > 0 then
      let def_items = Array[json.Item]
      for
        (ident, line, col, next_line, next_col, doc) in definitions.values()
      do
        def_items.push(json.Object(
          [ as (String, json.Item):
            ("identifier", ident)
            ("line", I128.from[USize](line))
            ("column", I128.from[USize](col))
            ("next_line", I128.from[USize](next_line))
            ("next_column", I128.from[USize](next_col))
            ("doc_string", doc) ]))
      end
      props.push(("definitions", json.Sequence(def_items)))
    end
    if contents.size() > 0 then
      let content_items = Array[json.Item]
      for (ident, line, col, next_line, next_col, doc) in contents.values() do
        content_items.push(json.Object(
          [ as (String, json.Item):
            ("identifier", ident)
            ("line", I128.from[USize](line))
            ("column", I128.from[USize](col))
            ("next_line", I128.from[USize](next_line))
            ("next_column", I128.from[USize](next_col))
            ("doc_string", doc) ]))
      end
      props.push(("contents", json.Sequence(content_items)))
    end
    if children.size() > 0 then
      let children_items = Array[json.Item]
      for child in children.values() do
        children_items.push(child.get_json())
      end
      props.push(("children", json.Sequence(children_items)))
    end
    json.Object(consume props)

primitive ParseScopeJson
  fun apply(scope_item: json.Item, parent: (Scope | None)): (Scope | String) =>
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
          "scope.name must be a string"
        end
      let scope = Scope(kind, name.clone(), parent)
      match try scope_obj("imports")? end
      | let seq: json.Sequence =>
        for item in seq.values() do
          match item
          | let obj: json.Object =>
            try
              (let ident, let path) =
                (obj("identifier")? as String box, obj("path")? as String box)
              scope.imports.push((ident.clone(), path.clone()))
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
              (let ident, let l, let c, let nl, let nc, let doc) =
                ( obj("identifier")? as String box
                , obj("line")? as I128
                , obj("column")? as I128
                , obj("next_line")? as I128
                , obj("next_column")? as I128
                , obj("doc_string")? as String box )
              scope.definitions.push(
                ( ident.clone()
                , USize.from[I128](l)
                , USize.from[I128](c)
                , USize.from[I128](nl)
                , USize.from[I128](nc)
                , doc.clone() ))
            end
          end
        end
      end
      match try scope_obj("contents")? end
      | let seq: json.Sequence =>
        for item in seq.values() do
          match item
          | let obj: json.Object =>
            try
              (let ident, let l, let c, let nl, let nc, let doc) =
                ( obj("identifier")? as String box
                , obj("line")? as I128
                , obj("column")? as I128
                , obj("next_line")? as I128
                , obj("next_column")? as I128
                , obj("doc_string")? as String box )
              scope.definitions.push(
                ( ident.clone()
                , USize.from[I128](l)
                , USize.from[I128](c)
                , USize.from[I128](nl)
                , USize.from[I128](nc)
                , doc.clone() ))
            end
          end
        end
      end
      match try scope_obj("children")? end
      | let seq: json.Sequence =>
        for item in seq.values() do
          match ParseScopeJson(item, scope)
          | let child: Scope =>
            scope.children.push(child)
          | let err: String =>
            return err
          end
        end
      end
      scope
    else
      "scope must be a JSON object"
    end
