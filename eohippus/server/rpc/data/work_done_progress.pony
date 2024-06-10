use json = "../../../json"

type ProgressToken is (I128 | String)

interface val WorkDoneProgressParams is RequestParams
  fun val workDoneToken(): (ProgressToken | None)

interface val PartialResultParams
  fun val partialResultToken(): (ProgressToken | None)
