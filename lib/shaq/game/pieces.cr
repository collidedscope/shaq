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

  def vision
    friends.flat_map &.vision self
  end

  def enemy_vision
    enemies.flat_map &.vision self
  end

  def attacked?(square)
    enemy_vision.includes? square
  end

  def king
    friends.find &.king? || raise "No #{turn} King?!"
  end
end
