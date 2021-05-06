class Shaq::Game
  def pieces
    board.select Piece
  end

  def pieces(side)
    pieces.select &.side.== side
  end

  def friends
    pieces.select &.side.== turn
  end

  def friends(piece)
    friends.select &.class.== piece
  end

  def enemies
    pieces.select &.side.!= turn
  end

  def enemies(piece)
    enemies.select &.class.== piece
  end

  def enemy_vision
    enemies.flat_map &.vision self
  end

  def king
    raise "No #{turn} King?!" unless king = friends.find &.king?
    king
  end
end
