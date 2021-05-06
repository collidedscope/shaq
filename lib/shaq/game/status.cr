class Shaq::Game
  def black?
    turn == Side::Black
  end

  def white?
    !black?
  end

  def other_side
    turn.other
  end

  def check?
    enemy_vision.includes? king.position
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
    draw? || checkmate?
  end

  def position
    {Util.fenalize(board), turn, castling, ep_target}
  end

  def occupancy
    board.each_with_index.sum { |e, i| (e ? 1u64 : 0u64) << i }
  end
end
