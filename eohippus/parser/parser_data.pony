class val ParserData[CH: ((U8 | U16) & UnsignedInteger[CH])]
  let _locator: String

  new val create(locator': String) =>
    _locator = locator'

  fun locator(): String => _locator
