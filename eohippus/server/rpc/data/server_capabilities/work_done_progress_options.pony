use json = "../../../../json"

use ".."

interface val WorkDoneProgressOptions is ResultData
  fun val workDoneProgress(): (Bool | None)

  fun val get_json_props(): Array[(String, json.Item)] =>
    let props = Array[(String, json.Item)]
    match workDoneProgress()
    | let bool: Bool =>
      props.push(("workDoneProgress", bool))
    end
    props

  fun val get_json(): json.Item =>
    json.Object(get_json_props())
