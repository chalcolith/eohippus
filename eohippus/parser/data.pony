type Locator is String

class val Data
  let locator: Locator

  new val create(locator': Locator) =>
    locator = locator'
