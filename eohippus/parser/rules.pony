use k = "kiuatan"
use ast = "../ast"

type Parser is k.Parser[U8, Data, ast.Node]
type Segment is k.Segment[U8]
type Loc is k.Loc[U8]
type Variable is k.Variable

type NamedRule is k.NamedRule[U8, Data, ast.Node]
type RuleNode is k.RuleNode[U8, Data, ast.Node]
type RuleNodeWithBody is k.RuleNodeWithBody[U8, Data, ast.Node]
type RuleNodeWithChildren is k.RuleNodeWithChildren[U8, Data, ast.Node]
type Single is k.Single[U8, Data, ast.Node]
type Literal is k.Literal[U8, Data, ast.Node]
type Conj is k.Conj[U8, Data, ast.Node]
type Disj is k.Disj[U8, Data, ast.Node]
type Star is k.Star[U8, Data, ast.Node]
type Look is k.Look[U8, Data, ast.Node]
type Neg is k.Neg[U8, Data, ast.Node]
type Error is k.Error[U8, Data, ast.Node]
type Bind is k.Bind[U8, Data, ast.Node]

type Result is k.Result[U8, Data, ast.Node]
type Success is k.Success[U8, Data, ast.Node]
type Failure is k.Failure[U8, Data, ast.Node]

type Action is k.Action[U8, Data, ast.Node]
type Bindings is k.Bindings[U8, Data, ast.Node]

primitive Ques
  fun apply(body: RuleNode, action: (Action | None) = None): RuleNode =>
    Star(body, 0, action, 1)

primitive Plus
  fun apply(body: RuleNode, action: (Action | None) = None): RuleNode =>
    Star(body, 1, action)
