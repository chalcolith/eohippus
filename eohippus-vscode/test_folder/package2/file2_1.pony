
class Foo
  "This is a class in a package"

  let n: USize "this is a field"

  new create(n': USize) =>
    """this is a constructor"""
    n = n'
