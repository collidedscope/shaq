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
    friends.flat_map &.vision
  end

  def enemy_vision
    enemies.flat_map &.vision
  end

  def attacked?(square)
    enemy_vision.includes? square
  end

  def king
    raise "No #{turn} King?!" unless found = friends.find &.king?
    found.as King
  end

  {% for piece in %w[Pawn Rook Knight Bishop Queen King] %}
    def {{piece.downcase.id}}s
      board.select {{piece.id}}
    end
  {% end %}
end
