// foo
// bar
actor Test
  let n: USize

  new create(n': USize) =>
    parse_task_id
    n = n' // one two three
