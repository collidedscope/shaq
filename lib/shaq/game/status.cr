class Shaq::Game
  delegate black?, white?, to: turn

  def other_side
    turn.other
  end

  def check?
    attacked? king.position
  end

  def checkmate?
    check? && legal_moves.empty?
  end

  def stalemate?
    legal_moves.empty? && !check?
  end

  def bare_king?
    friends.all? &.king?
  end

  def insufficient_material?
    return false if friends.any? Pawn | Rook | Queen

    ours, theirs = material.values_at turn, other_side

    # If all we have is a Knight, the enemy King can still be helpmated if any
    # of his friends can block his escape square: https://lichess.org/WXyx2mxH
    # The Queen is incapable of blocking him in since she can take the Knight.
    return true if ours == {Knight => 1} && theirs.keys == [Queen]

    # Similarly for Bishops all of the same color, helpmate is still possible
    # if the opposing side has any Pawns, Knights, or opposite-colored Bishops
    # that could prevent the King's escape: https://lichess.org/o3PCfb98
    if ours.keys == [Bishop]
      colors = friends(Bishop).map(&.color).uniq
      return false if colors.size == 2
      enemies.none? { |e| e.pawn? || e.knight? || e.bishop? && e.color != colors[0] }
    else
      bare_king?
    end
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
