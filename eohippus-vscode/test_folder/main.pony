// line comment
/* block comment */

actor Main
  new create(env: Env) =>
    'c' // character literal
    '\'' // string literal
    "string \" literal"
    """triple string"""

    addressof foo

    env.out.print("Hello, world!")

    for i in Range(1, 123) do
      foo
    end

    let y = 3.14e-12 + a
    let z = 0x1ef_dec + false
    let b = 0b1000_101_1

    this.bar(where n = 1.3)

    let x = true

  be behavior()

  fun function()

trait Trait

interface Interface

struct Struct
