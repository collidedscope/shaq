class Shaq::Game
  def black?
    turn == Side::Black
  end

  def white?
    !black?
  end

  def other_side
    black? ? Side::White : Side::Black
  end

  def check?
    raise "No #{turn} King?!" unless king = friends.find &.king?
    enemies.flat_map(&.vision self).includes? king.position
  end

  def checkmate?
    check? && legal_moves.empty?
  end

  def stalemate?
    legal_moves.empty? && !check?
  end

  def insufficient_material?
    pieces.all? &.king?
  end

  def repetition?(n = 3)
    positions.any? &.[1].>= n
  end

  def draw?
    repetition? || stalemate? || insufficient_material? || hm_clock >= 100
  end

  def over?
    draw? || checkmate? || stalemate?
  end

  def occupancy
    board.each_with_index.sum { |e, i| (e ? 1u64 : 0u64) << i }
  end
end
