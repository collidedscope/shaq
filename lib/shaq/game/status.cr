class Shaq::Game
  delegate black?, white?, to: turn

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
end
