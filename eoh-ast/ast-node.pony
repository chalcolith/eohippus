
use "kiuatan"

type AstNode[CH: (U8 | U16)] = FileItem[CH]

class box Token[CH: (U8 | U16)]
  embed start: ParseLoc[CH] val
  embed next: ParseLoc[CH] val

  new create(start': ParseLoc[CH] val, next': ParseLoc[CH] val) =>
    start = start'
    next = next'

class FileItem[CH: (U8 | U16)]
  embed token: Token[CH]

  new create(start': ParseLoc[CH] val, next': ParseLoc[CH] val) =>
    token = Token(start', next')
