module Shaq::Util
  extend self

  def teleport?(from, to)
    (from % 8 - to % 8).abs > 2
  end

  def traverse(board, piece, heading)
    squares = [] of Int32
    position = piece.position

    loop do
      target = position + heading
      break if !((0..63) === target) || teleport? position, target
      squares << (position = target)
      break if piece.friend? board[target]
    end

    squares
  end
end
