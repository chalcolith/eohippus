
use "itertools"
use "ponytest"
use "promises"

use "kiuatan"
use "../ast"

primitive Assert[CH: (U8 | U16)]
  fun all(h: TestHelper, promises: ReadSet[Promise[Bool]]) =>
    Promises[Bool].join(promises.values())
      .next[None]({(results) => h.complete(Iter[Bool](results.values()).all({x} => x}))})
    h.long_test(10_000_000_000)

  fun match(h: TestHelper,
    rule: Rule[CH, AstNode[CH]],
    source: ReadSeq[Segment[S]] val,
    start_index: USize,
    expected_match: Bool,
    expected_length: USize = 0,
    expected_value: (V | None) = None,
    expected_error: (String | None) = None) : Promise[Bool]
  =>
    let segments = Lists[Segment[S]].from(source.values())
    let start = Loc[CH](segments) + start_index
    let expected_next = start + expected_length

    let promise = Promise[Bool]
    let parser = Parser[CH, AstNode[CH]]
    parser.parse(rule, {(result: Result[CH, AstNode[CH]]) =>
      match result
      | let success: Success[S, V] =>
        if expected_match then
          if not (h.assert_eq[Loc[CH]](start, success.start,
            "actual start " + success.start.string() + " != expected " +
            start.string()) and h.assert_eq[Loc[CH]](expected_next, success.next,
            "actual next " + success.next.string() + " != expected " +
            expected_next.string()))
          then
            promise(false)
          else
            match expected_value =>
            | None => promise(true)
            | let expected_value' =>
              match success.value()
              | None =>
                h.fail("expected value ")
          end
        else
          h.fail("match succeeded when it should have failed")
          promise(false)
        end
      | let failure: Failure[S, V] =>
      end
    })
    promise
