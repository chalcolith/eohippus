use json = "../json"

trait val NodeData
  fun name(): String

  fun add_json_props(props: Array[(String, json.Item)])

  fun val clone(old_children: NodeSeq, new_children: NodeSeq): NodeData ?

trait val NodeDataWithValue[V: Any val] is NodeData
  fun value(): V
