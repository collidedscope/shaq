module Shaq::Util
  extend self

  def teleport?(from, to)
    (from % 8 - to % 8).abs > 2
  end

  def rank(position)
    8 - position // 8
  end

  def file(position)
    'a' + position % 8
  end

  def to_algebraic(position)
    raise "Invalid position: #{position}" unless (0..63) === position

    rank, file = position.divmod 8
    "#{'a' + file}#{8 - rank}"
  end

  def from_algebraic(square)
    raise "Invalid square: #{square}" unless square.match /^[a-h][1-8]$/

    file, rank = square.chars
    ('8' - rank) * 8 + (file - 'a')
  end

  def traverse(board, piece, heading)
    squares = [] of Int32
    position = piece.position

    loop do
      target = position + heading
      break if !((0..63) === target) || teleport? position, target
      squares << (position = target)
      break if board[target]
    end

    squares
  end
end
