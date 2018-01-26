
use "collections"

use "kiuatan"

type EohInput is (U8 | U16)

type AstNode[CH: EohInput val] is
  ( FileItem[CH]
  )

class box Token[CH: EohInput val]
  embed start: ParseLoc[CH] val
  embed next: ParseLoc[CH] val

  new create(start': ParseLoc[CH] val, next': ParseLoc[CH] val) =>
    start = recover ParseLoc[CH].from_loc(start') end
    next = recover ParseLoc[CH].from_loc(next') end

class FileItem[CH: EohInput val]
  embed token: Token[CH]

  new create(start': ParseLoc[CH] val, next': ParseLoc[CH] val) =>
    token = Token[CH](start', next')
