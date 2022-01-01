type Locator is String

class val Data
  let _locator: Locator

  new val create(locator': Locator) =>
    _locator = locator'

  fun locator(): Locator => _locator
