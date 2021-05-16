module Shaq
  STANDARD = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
  VALUES   = {Queen => 9, Rook => 5, Bishop => 3, Knight => 3, Pawn => 1}
  PIECES   = {P: Pawn, R: Rook, N: Knight, B: Bishop, Q: Queen, K: King}
  LETTERS  = PIECES.to_h.invert
  ROYAL    = {-9, -8, -7, -1, 1, 7, 8, 9}
  UCI      = /^([a-h][1-8]){2}[qnrb]?/

  BACK_RANKS = {Side::White => 1, Side::Black => 8}
  PAWN_RANKS = {Side::White => 2, Side::Black => 7}

  LONG_CASTLE = {
    Side::Black => {king: 2, path: 2..3, rook: {0, 3}},
    Side::White => {king: 58, path: 58..59, rook: {56, 59}},
  }
  SHORT_CASTLE = {
    Side::Black => {king: 6, path: 5..6, rook: {7, 5}},
    Side::White => {king: 62, path: 61..62, rook: {63, 61}},
  }

  MOORE_NEIGHBORHOODS = {% begin %} {
      {% for i in 0..63 %} [
        {% for j in ROYAL.map &.+ i %}
          {% if 0 <= j && j <= 63 && {-1, 0, 1}.includes? i % 8 - j % 8 %}
            {{j}}, {% end %} {% end %} ], {% end %} } {% end %}

  KNIGHT_VISION = {% begin %} {
      {% for i in 0..63 %} [
        {% for j in {-17, -15, -10, -6, 6, 10, 15, 17}.map &.+ i %}
          {% if 0 <= j && j <= 63 && {-2, -1, 1, 2}.includes? i % 8 - j % 8 %}
            {{j}}, {% end %} {% end %} ], {% end %} } {% end %}
end
