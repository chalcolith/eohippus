use "collections/persistent"
use "itertools"
use "ponytest"
use "promises"

use ast = "../ast"
use parser = "../parser"

primitive _Assert
  fun test_all(h: TestHelper, promises: ReadSeq[Promise[Bool]]) =>
    Promises[Bool].join(promises.values())
      .next[None]({(results) =>
        h.complete(Iter[Bool](results.values()).all({(x) => x }))
      })
    h.long_test(10_000_000_000)

  fun test_match(h: TestHelper,
    rule: parser.NamedRule,
    source: ReadSeq[parser.Segment] val,
    start_index: USize,
    data: parser.Data,
    expected_match: Bool,
    expected_length: USize = 0,
    expected_value: (ast.Node | None) = None,
    expected_error: (String | None) = None) : Promise[Bool]
  =>
    let segments = Lists[parser.Segment].from(source.values())
    let start = parser.Loc(segments) + start_index
    let expected_next = start + expected_length

    let promise = Promise[Bool]
    let pony_parser = parser.Parser(segments)
    pony_parser.parse(rule, data,
      {(result, value) =>
        match result
        | let success: parser.Success =>
          if expected_match then
            if h.assert_eq[parser.Loc](start, success.start, "actual start "
              + success.start.string() + " != expected " + start.string())
              and h.assert_eq[parser.Loc](expected_next, success.next,
                "actual next " + success.next.string() + " != expected "
                + expected_next.string())
            then
              match expected_value
              | None =>
                promise(true)
              | let expected_value': ast.Node =>
                match value
                | None =>
                  h.fail("expected value " + expected_value.string()
                    + "; got None")
                  promise(false)
                | let actual_value: ast.Node =>
                  promise(h.assert_eq[ast.Node](expected_value', actual_value))
                end
              end
            else
              promise(false)
            end
          else
            h.fail("match succeeded when it should have failed")
            promise(false)
          end
        | let failure: parser.Failure =>
          if expected_match then
            h.fail("match failed; should have succeeded")
            promise(false)
          else
            match expected_error
            | let expected_error': String =>
              if expected_error' != "" then
                let actual_error = failure.get_message()
                if not h.assert_true(actual_error.contains(expected_error'),
                  "'" + actual_error + "' should have contained '" +
                  expected_error' + "'")
                then
                  promise(false)
                else
                  promise(true)
                end
              else
                promise(true)
              end
            else
              promise(true)
            end
          end
        end
      },
      start)
    promise
