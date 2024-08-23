
class Foo
  "This is a class in package2"

  let foo_n: USize "this is a field foo_n"

  new create(n: USize) =>
    """Foo constructor"""
    foo_n = n

  new do(n: USize) =>
    foo_n = n
