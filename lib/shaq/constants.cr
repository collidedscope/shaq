module Shaq
  STANDARD = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
  VALUES   = {Queen => 9, Rook => 5, Bishop => 3, Knight => 3, Pawn => 1}
  PIECES   = {P: Pawn, R: Rook, N: Knight, B: Bishop, Q: Queen, K: King}
  LETTERS  = PIECES.to_h.invert
  ROYAL    = {-9, -8, -7, -1, 1, 7, 8, 9}
  UCI      = /^([a-h][1-8]){2}[qnrb]?/
end
