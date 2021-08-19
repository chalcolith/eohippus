use k = "kiuatan"
use "../ast"

type Parser is k.Parser[U8, Data, Node]
type Segment is k.Segment[U8]
type Loc is k.Loc[U8]

type NamedRule is k.NamedRule[U8, Data, Node]
type Single is k.Single[U8, Data, Node]
type Literal is k.Literal[U8, Data, Node]
type Conj is k.Conj[U8, Data, Node]
type Disj is k.Disj[U8, Data, Node]
type Star is k.Star[U8, Data, Node]
type Neg is k.Neg[U8, Data, Node]

type Result is k.Result[U8, Data, Node]
type Success is k.Success[U8, Data, Node]
type Failure is k.Failure[U8, Data, Node]
