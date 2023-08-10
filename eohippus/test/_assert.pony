use "collections/persistent"
use "itertools"
use "pony_test"
use "promises"

use ast = "../ast"
use parser = "../parser"

interface val _Assertion
  fun apply(node: ast.Node): Bool

primitive _Assert
  fun test_all(h: TestHelper, promises: ReadSeq[Promise[Bool]]) =>
    Promises[Bool].join(promises.values())
      .next[None]({(results) =>
        h.complete(Iter[Bool](results.values()).all({(x) => x }))
      })
    h.long_test(10_000_000_000)

  // fun test_json(
  //   h: TestHelper,
  //   rule: parser.NamedRule,
  //   source: ReadSeq[parser.Segment] val,
  //   data: parser.Data,
  //   expected_json: (String | None)) : Promise[Bool]
  // =>
  //   let segments = Lists[parser.Segment].from(source.values())
  //   let start = parser.Loc(segments)
  //   let promise = Promise[Bool]
  //   let pony_parser = parser.Parser(segments)
  //   let callback =
  //     recover val
  //       {(r: (parser.Success | parser.Failure), v: ast.NodeSeq[ast.Node]) =>
  //         match r
  //         | let success: parser.Success =>
  //           match expected_json
  //           | let expected_str: String =>
  //             let actual_str =
  //               recover val
  //                 let json = String
  //                 for v' in v.values() do
  //                   json.append(v'.info().string())
  //                 end
  //                 json
  //               end

  //             promise(h.assert_eq[String](expected_str, actual_str))
  //           else
  //             h.fail("Match succeeded when it should have failed.")
  //             promise(false)
  //           end
  //         | let failure: parser.Failure =>
  //           match expected_json
  //           | let expected_str: String =>
  //             h.fail("Match failed when it should have succeeded: "
  //               + failure.get_message())
  //             promise(false)
  //           end
  //         end
  //         promise(true)
  //       }
  //     end
  //   pony_parser.parse(rule, data, callback)
  //   promise

//   fun test_match(
//     h: TestHelper,
//     rule: parser.NamedRule,
//     source: ReadSeq[parser.Segment] val,
//     start_index: USize,
//     data: parser.Data,
//     expected_match: Bool,
//     expected_length: USize = 0,
//     expected_value: (ast.Node | None) = None,
//     expected_error: (String | None) = None,
//     assertion: (_Assertion | None) = None) : Promise[Bool]
//   =>
//     let segments = Lists[parser.Segment].from(source.values())
//     let start = parser.Loc(segments) + start_index
//     let expected_next = start + expected_length

//     let promise = Promise[Bool]
//     let pony_parser = parser.Parser(segments)
//     let callback =
//       recover val
//         _MatchCallback(h, start, expected_match, expected_length,
//           expected_value, expected_error, assertion, promise)
//       end

//     pony_parser.parse(rule, data, callback, start)
//     promise

// class _MatchCallback
//   let _h: TestHelper
//   let _start: parser.Loc
//   let _expected_match: Bool
//   let _expected_length: USize
//   let _expected_value: (ast.Node | None)
//   let _expected_error: (String | None)
//   let _assertion: (_Assertion | None)
//   let _promise: Promise[Bool]

//   new create(h: TestHelper, start: parser.Loc,
//     expected_match: Bool, expected_length: USize,
//     expected_value: (ast.Node | None), expected_error: (String | None),
//     assertion: (_Assertion | None),
//     promise: Promise[Bool])
//   =>
//     _h = h
//     _start = start
//     _expected_match = expected_match
//     _expected_length = expected_length
//     _expected_value = expected_value
//     _expected_error = expected_error
//     _assertion = assertion
//     _promise = promise

//   fun apply(result: (parser.Success | parser.Failure),
//     values: ast.NodeSeq[ast.Node])
//   =>
//     _promise(
//       match result
//       | let success: parser.Success =>
//         _handle_success(success, values)
//       | let failure: parser.Failure =>
//         _handle_failure(failure)
//       end
//     )

//   fun _handle_success(success: parser.Success,
//     values: ast.NodeSeq[ast.Node]): Bool
//   =>
//     if not _expected_match then
//       _h.fail("match succeeded when it should have failed")
//       return false
//     end

//     if not _h.assert_eq[parser.Loc](_start, success.start, "actual start "
//       + success.start.string() + " != expected " + _start.string())
//     then
//       return false
//     end

//     let expected_next = _start + _expected_length
//     if not _h.assert_eq[parser.Loc](expected_next, success.next, "actual next "
//       + success.next.string() + " != expected " + expected_next.string())
//     then
//       return false
//     end

//     match _expected_value
//     | let expected_value': ast.Node =>
//       try
//         let actual_value = values(0)?
//         if not _h.assert_eq[ast.Node](expected_value', actual_value) then
//           return false
//         end
//       else
//         _h.fail("expected value " + expected_value'.string() + "; got nothing")
//         return false
//       end
//     end

//     match _assertion
//     | let assertion': _Assertion =>
//       try
//         let actual_value = values(0)?
//         if not assertion'(actual_value) then
//           _h.fail("assertion failed")
//           return false
//         end
//       else
//         _h.fail("got no value for assertion")
//         return false
//       end
//     end
//     true

//   fun _handle_failure(failure: parser.Failure): Bool =>
//     if _expected_match then
//       _h.fail("match failed; should have succeeded: " + failure.get_message())
//       return false
//     end

//     match _expected_error
//     | let expected_error': String =>
//       if expected_error' != "" then
//         let actual_error = failure.get_message()
//         if not _h.assert_true(actual_error.contains(expected_error'),
//           "'" + actual_error + "' should have contained '" + expected_error'
//           + "'")
//         then
//           return false
//         end
//       end
//     end
//     true
