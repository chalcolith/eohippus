class val ServerConfig
  let ponyc_executable: (String | None)

  new create(ponyc_executable': (String | None)) =>
    ponyc_executable = ponyc_executable'
