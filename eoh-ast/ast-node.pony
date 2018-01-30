
use "collections"

use "kiuatan"

type AstNode[CH: (Unsigned & Integer[CH])] is
  ( FileItem[CH]
  )

class box Token[CH: (Unsigned & Integer[CH])]
  embed start: ParseLoc[CH] val
  embed next: ParseLoc[CH] val

  new create(start': ParseLoc[CH] val, next': ParseLoc[CH] val) =>
    start = recover ParseLoc[CH].from_loc(start') end
    next = recover ParseLoc[CH].from_loc(next') end

class FileItem[CH: (Unsigned & Integer[CH])]
  embed token: Token[CH]

  new create(start': ParseLoc[CH] val, next': ParseLoc[CH] val) =>
    token = Token[CH](start', next')
