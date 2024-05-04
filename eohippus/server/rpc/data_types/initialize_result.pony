use json = "../../../json"

use s_caps = "server_capabilities"
use ".."

interface val InitializeResult is ResultData
  fun val capabilities(): s_caps.ServerCapabilities
  fun val serverInfo(): (ServerInfo | None)

  fun val get_json(): json.Item val =>
    recover val
      let props =
        [ as (String, json.Item): ("capabilities", capabilities().get_json()) ]
      match serverInfo()
      | let si: ServerInfo =>
        props.push(("serverInfo", si.get_json()))
      end
      json.Object(props)
    end

interface val ServerInfo is ResultData
  fun val name(): String
  fun val version(): (String | None)

  fun val get_json(): json.Item val =>
    recover val
      let props = [ as (String, json.Item): ("name", name()) ]
      match version()
      | let v: String =>
        props.push(("version", v))
      end
      json.Object(props)
    end
