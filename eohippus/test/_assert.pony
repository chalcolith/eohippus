use "collections/persistent"
use "itertools"
use "pony_test"
use "promises"

use ast = "../ast"
use json = "../json"
use parser = "../parser"
use ".."

interface val _Assertion
  fun apply(node: ast.Node): Bool

primitive _Assert
  fun test_all(h: TestHelper, promises: ReadSeq[Promise[Bool]]) =>
    Promises[Bool]
      .join(promises.values())
      .next[None](
        {(results: Array[Bool] val) =>
          let succeeded = Iter[Bool](results.values()).all({(x) => x })
          if not succeeded then
            h.fail("One or more tests failed!")
          end
          h.complete(succeeded) },
        {() =>
          h.fail("One or more tests was rejected!")
          h.complete(false) })
    h.long_test(100_000_000_000)

  fun test_match(
    h: TestHelper,
    rule: parser.NamedRule val,
    data: parser.Data,
    source: String,
    expected: (String | None),
    ignore_error_sections: Bool = false)
    : Promise[Bool]
  =>
    let promise = Promise[Bool]
    let segments = Cons[parser.Segment](source, Nil[parser.Segment])
    let start = parser.Loc(segments, 0)
    let pony_parser = parser.Parser(segments)
    let callback =
      recover val
        {(r: (parser.Success | parser.Failure), v: ast.NodeSeq) =>
          var test_succeeded = true

          match r
          | let success: parser.Success =>
            match expected
            | let expected_str: String =>
              if expected_str.size() == 0 then
                test_succeeded = h.assert_true(v.size() == 0)
              else
                (let es_ok, let es_msg) = _Assert._check_error_sections(v)
                if (not ignore_error_sections) and (not es_ok) then
                  h.fail("Error sections found: " + es_msg)
                  test_succeeded = false
                else
                  try
                    let actual_json = v(0)?.get_json()
                    match json.Parse(expected_str)
                    | let expected_json: json.Item =>
                      if v.size() != 1 then
                        h.fail(
                          "Expected exactly one action value; got " +
                          v.size().string())
                        test_succeeded = false
                      else
                        (let res, let err) =
                          json.Subsumes(expected_json, actual_json)
                        test_succeeded = h.assert_true(
                          res,
                          "EXPECTED\n" + expected_json.string() +
                          "\n\nACTUAL\n" + actual_json.string() + "\n: " + err)
                      end
                    | let parse_error: json.ParseError =>
                      h.fail(
                        "Could not parse JSON '" + expected_str + "' (" +
                        parse_error.index.string() + "): " +
                        parse_error.message)
                      test_succeeded = false
                    end
                  else
                    h.fail("Unable to get action value!")
                    test_succeeded = false
                  end
                end
              end
            else
              h.fail("Match succeeded when it should have failed.")
              test_succeeded = false
            end
          | let failure: parser.Failure =>
            match expected
            | let _: String =>
              h.fail("Match failed when it should have succeeded: " +
                failure.get_message())
              test_succeeded = false
            end
          end
          promise(test_succeeded)
        }
      end
    pony_parser.parse(rule, data, callback)
    promise

  fun test_with(
    h: TestHelper,
    rule: parser.NamedRule val,
    data: parser.Data,
    source: String,
    assertion: {(parser.Success, ast.NodeSeq): (Bool, String)} val,
    ignore_error_sections: Bool = false)
    : Promise[Bool]
  =>
    let promise = Promise[Bool]
    let segments = Cons[parser.Segment](source, Nil[parser.Segment])
    let pony_parser = parser.Parser(segments)
    let callback =
      recover val
        {(r: (parser.Success | parser.Failure), v: ast.NodeSeq) =>
          match r
          | let success: parser.Success =>
            (let es_ok, let es_msg) = _Assert._check_error_sections(v)
            if (not ignore_error_sections) and (not es_ok) then
              h.fail("Error sections found: " + es_msg)
              promise(false)
            else
              (let succeeded, let message) = assertion(success, v)
              if succeeded then
                promise(true)
              else
                h.fail("Assertion failed: " + message)
                promise(false)
              end
            end
          | let failure: parser.Failure =>
            h.fail("Test failed: " + failure.get_message())
            promise(false)
          end
        }
      end
    pony_parser.parse(rule, data, callback)
    promise

  fun _check_error_sections(nodes: ast.NodeSeq): (Bool, String) =>
    recover
      let msg = String
      for node in nodes.values() do
        _get_error_sections(node, msg)
      end
      (msg.size() == 0, msg)
    end

  fun _get_error_sections(node: ast.Node, msg: String ref) =>
    match node
    | let es: ast.NodeWith[ast.ErrorSection] =>
      if msg.size() > 0 then
        msg.append("; ")
      end
      msg.append(es.data().message)
      msg.append(": '")
      let si = es.src_info()
      match (si.start, si.next)
      | (let s: parser.Loc, let n: parser.Loc) =>
        let code = String.>concat(s.values(n))
        msg.append(StringUtil.escape(code))
      end
      msg.append("'")
    end
    for child in node.children().values() do
      _get_error_sections(child, msg)
    end
