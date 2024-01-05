use json = "../json"

trait val NodeData
  fun name(): String

  fun add_json_props(props: Array[(String, json.Item)])

trait val NodeDataWithValue[T: Any val] is NodeData
  fun value(): T
