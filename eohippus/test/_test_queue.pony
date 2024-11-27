use "pony_test"

use ".."

primitive _TestQueue
  fun apply(test: PonyTest) =>
    test(_TestQueueInsertFew)
    test(_TestQueueInsertMany)

class iso _TestQueueInsertFew is UnitTest
  fun name(): String => "queue/insert_few"
  fun exclusion_group(): String => "utils"

  fun apply(h: TestHelper) =>
    let q = Queue[USize]

    q.push(1)
    q.push(2)
    q.push(3)

    try
      h.assert_eq[USize](1, q.pop()?)
      q.push(4)
      h.assert_eq[USize](2, q.pop()?)
      h.assert_eq[USize](3, q.pop()?)
      h.assert_eq[USize](4, q.pop()?)
    else
      h.fail("queue error")
    end

class iso _TestQueueInsertMany is UnitTest
  fun name(): String => "queue/insert_many"
  fun exclusion_group(): String => "utils"

  fun apply(h: TestHelper) =>
    let q = Queue[USize]

    let space = q.space()
    var i: USize = 0
    while i < ((space * 2) / 3) do
      q.push(i)
      i = i + 1
    end

    try
      i = 0
      while i < (space / 2) do
        h.assert_eq[USize](i, q.pop()?)
        i = i + 1
      end
    else
      h.fail("queue error 1")
    end

    try
      i = 0
      while i < (space / 2) do
        q.push(i + ((space * 2) / 3))
        i = i + 1
      end

      i = space / 2
      while q.size() > 0 do
        h.assert_eq[USize](i, q.pop()?)
        i = i + 1
      end
    else
      h.fail("queue error 2")
    end
