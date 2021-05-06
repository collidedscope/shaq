class Shaq::Game
  VALUES = {Queen => 9, Rook => 5, Bishop => 3, Knight => 3, Pawn => 1}

  alias PieceType = (Queen | Rook | Bishop | Knight | Pawn).class
  alias Material = Hash(PieceType, Int32)

  def material(side)
    pieces(side).reject(&.king?).map &.class
  end

  def material
    {Side::Black, Side::White}.map { |side| {side, material(side).tally} }.to_h
  end

  def material_value(material)
    material.sum { |piece, amount| VALUES[piece] * amount }
  end

  def material_value
    material.transform_values &->material_value(Material)
  end

  def material_imbalance
    black, white = material.values
    imbalance = {Side::Black => Material.new, Side::White => Material.new}

    VALUES.each_key do |piece|
      diff = black.fetch(piece, 0) - white.fetch(piece, 0)
      imbalance[Side::Black][piece] = diff if diff > 0
      imbalance[Side::White][piece] = -diff if diff < 0
    end

    imbalance
  end

  def material_advantage(side)
    values = material_value
    values[side] - values[side.other]
  end
end
