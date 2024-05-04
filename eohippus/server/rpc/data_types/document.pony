use json = "../../../json"

interface val DocumentFilter is SendData
  fun val language(): (String | None)
  fun val scheme(): (String | None)
  fun val pattern(): (String | None)

  fun val get_json(): json.Item =>
    let props = Array[(String, json.Item)]
    match language()
    | let str: String =>
      props.push(("language", str))
    end
    match scheme()
    | let str: String =>
      props.push(("scheme", str))
    end
    match pattern()
    | let str: String =>
      props.push(("scheme", str))
    end
    json.Object(props)

type DocumentSelector is Seq[DocumentFilter]
