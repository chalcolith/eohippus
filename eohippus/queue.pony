
class Queue[A]
  embed _array: Array[A]
  var _size: USize
  var _start: USize
  var _next: USize

  new create(space': USize = 0) =>
    _array = Array[A](space')
    _size = 0
    _start = 0
    _next = 0

  fun size(): USize =>
    _size

  fun space(): USize =>
    _array.space()

  fun apply(i: USize): this->A ? =>
    if i >= _size then
      error
    end
    let index = (_start + i) % _array.size()
    _array(index)?

  fun ref shift(): A ? =>
    if _size == 0 then
      error
    end
    let index = _start
    _start = (_start + 1) % _array.size()
    _size = _size - 1
    _array(index)?

  fun ref push(value: A) =>
    if _size < _array.size() then
      try
        if _next == _array.size() then
          _next = 0
        end
        _array.update(_next, consume value)?
        _next = _next + 1
        _size = _size + 1
      end
    else
      try
        _array.insert(_next, consume value)?
        if _start > _next then
          _start = _start + 1
        end
        _next = _next + 1
        _size = _size + 1
      end
    end
