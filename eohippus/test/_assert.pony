
use "collections/persistent"
use "itertools"
use "ponytest"
use "promises"

use "kiuatan"

use "../ast"

primitive _Assert[CH: (U8 | U16)]
  fun test_all(h: TestHelper, promises: ReadSeq[Promise[Bool]]) =>
    Promises[Bool].join(promises.values())
      .next[None]({(results) =>
        h.complete(Iter[Bool](results.values()).all({(x) => x }))
      })
    h.long_test(10_000_000_000)

  fun test_match(h: TestHelper,
    rule: Rule[CH, SrcNode[CH]],
    source: ReadSeq[Segment[CH]] val,
    start_index: USize,
    expected_match: Bool,
    expected_length: USize = 0,
    expected_value: (SrcNode[CH] | None) = None,
    expected_error: (String | None) = None) : Promise[Bool]
  =>
    let segments = Lists[Segment[CH]].from(source.values())
    let start = Loc[CH](segments) + start_index
    let expected_next = start + expected_length

    let promise = Promise[Bool]
    let parser = Parser[CH, SrcNode[CH]](segments)
    parser.parse(rule, {(result: Result[CH, SrcNode[CH]]) =>
      match result
      | let success: Success[CH, SrcNode[CH]] =>
        if expected_match then
          if h.assert_eq[Loc[CH]](start, success.start, "actual start "
            + success.start.string() + " != expected " + start.string())
            and h.assert_eq[Loc[CH]](expected_next, success.next, "actual next "
            + success.next.string() + " != expected " + expected_next.string())
          then
            match expected_value
            | None =>
              promise(true)
            | let expected_value': SrcNode[CH] =>
              match success.value()
              | None =>
                h.fail("expected value " + expected_value.string()
                  + "; got None")
                promise(false)
              | let actual_value: SrcNode[CH] =>
                promise(h.assert_eq[SrcNode[CH]](expected_value', actual_value))
              end
            end
          else
            promise(false)
          end
        else
          h.fail("match succeeded when it should have failed")
          promise(false)
        end
      | let failure: Failure[CH, SrcNode[CH]] =>
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
    })
    promise
