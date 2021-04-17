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
      break unless 0 <= target < 64
      break if piece.friendly?(board[target]) || teleport?(position, target)
      squares << (position = target)
    end

    squares
  end
end
