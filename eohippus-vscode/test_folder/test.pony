
use pk2 = "package2"

class One is MainTrait
  "Class One in the test_folder package"

  let one_a: USize "A field one_a"

  new create() =>
    "One constructor"
    let foo = pk2.Foo
    let bar = one_a

class Two is MainInterface
  "Class Two in the test_folder package"

  let two_a: USize "A field two_a"

  new create() =>
    "Two constructor"
    let s = MainStruct

class Three
  "Class Three in the test_folder package"

  new create() =>
    "Three constructor"
    None
