use json = "../json"

primitive Keywords
  """The source of truth for the string values of keywords."""

  fun kwd_actor(): String => "actor"
  fun kwd_addressof(): String => "addressof"
  fun kwd_and(): String => "and"
  fun kwd_as(): String => "as"
  fun kwd_be(): String => "be"
  fun kwd_box(): String => "box"
  fun kwd_break(): String => "break"
  fun kwd_class(): String => "class"
  fun kwd_compile_error(): String => "compile_error"
  fun kwd_compile_intrinsic(): String => "compile_intrinsic"
  fun kwd_consume(): String => "consume"
  fun kwd_continue(): String => "continue"
  fun kwd_digestof(): String => "digestof"
  fun kwd_do(): String => "do"
  fun kwd_else(): String => "else"
  fun kwd_elseif(): String => "elseif"
  fun kwd_embed(): String => "embed"
  fun kwd_end(): String => "end"
  fun kwd_error(): String => "error"
  fun kwd_false(): String => "false"
  fun kwd_for(): String => "for"
  fun kwd_fun(): String => "fun"
  fun kwd_hash_alias(): String => "#alias"
  fun kwd_hash_any(): String => "#any"
  fun kwd_hash_read(): String => "#read"
  fun kwd_hash_send(): String => "#send"
  fun kwd_hash_share(): String => "#share"
  fun kwd_if(): String => "if"
  fun kwd_ifdef(): String => "ifdef"
  fun kwd_iftype(): String => "iftype"
  fun kwd_in(): String => "in"
  fun kwd_interface(): String => "interface"
  fun kwd_is(): String => "is"
  fun kwd_iso(): String => "iso"
  fun kwd_let(): String => "let"
  fun kwd_loc(): String => "__loc"
  fun kwd_match(): String => "match"
  fun kwd_new(): String => "new"
  fun kwd_not(): String => "not"
  fun kwd_object(): String => "object"
  fun kwd_or(): String => "or"
  fun kwd_primitive(): String => "primitive"
  fun kwd_ref(): String => "ref"
  fun kwd_recover(): String => "recover"
  fun kwd_repeat(): String => "repeat"
  fun kwd_return(): String => "return"
  fun kwd_struct(): String => "struct"
  fun kwd_tag(): String => "tag"
  fun kwd_then(): String => "then"
  fun kwd_this(): String => "this"
  fun kwd_trait(): String => "trait"
  fun kwd_trn(): String => "trn"
  fun kwd_true(): String => "true"
  fun kwd_try(): String => "try"
  fun kwd_type(): String => "type"
  fun kwd_until(): String => "until"
  fun kwd_use(): String => "use"
  fun kwd_val(): String => "val"
  fun kwd_var(): String => "var"
  fun kwd_where(): String => "where"
  fun kwd_while(): String => "while"
  fun kwd_with(): String => "with"
  fun kwd_xor(): String => "xor"

class val Keyword is NodeData
  let string: String

  new val create(string': String) =>
    string = string'

  fun name(): String => "Keyword"

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData =>
    this

  fun add_json_props(props: Array[(String, json.Item)]) =>
    props.push(("string", string))
