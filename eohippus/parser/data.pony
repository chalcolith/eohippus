class val Data
  let _locator: String

  new val create(locator': String) =>
    _locator = locator'

  fun locator(): String => _locator
