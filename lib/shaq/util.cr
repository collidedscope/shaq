module Shaq::Util
  extend self

  def inbounds?(from, to)
    0 <= to <= 63 && (from % 8 - to % 8).abs < 3
  end

  def to_algebraic(position)
    return '-' unless position
    raise "Invalid position: #{position}" unless 0 <= position <= 63

    rank, file = position.divmod 8
    "#{'a' + file}#{8 - rank}"
  end

  def from_algebraic(square)
    raise "Invalid square: #{square}" unless square.match /^[a-h][1-8]$/

    file, rank = square.chars
    ('8' - rank) * 8 + (file - 'a')
  end

  def to_uci(from, to)
    promoting = to >= 64
    promo, to = to.divmod 64

    "#{to_algebraic from}#{to_algebraic to}#{"qnrb"[promo] if promoting}"
  end

  def from_uci(uci)
    raise "Invalid UCI: #{uci}" unless uci.match UCI

    from, to, promo = uci[0, 2], uci[2, 2], uci[4]?
    promo = promo ? "qnrb".index(promo).not_nil! : 0

    {from_algebraic(from), promo << 6 | from_algebraic(to)}
  end

  def fenalize(board)
    board.map { |piece|
      next '.' unless piece

      letter = LETTERS[piece.class].to_s
      piece.black? ? letter.downcase : letter
    }.join.scan(/.{8}/).map(&.[0].gsub /\.+/, &.size).join '/'
  end
end
