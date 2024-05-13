use json = "../../../json"

type ProgressToken is (I128 | String)

interface val WorkDoneProgressParams is RequestParams
  fun val workDoneToken(): (ProgressToken | None)
