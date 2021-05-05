class Shaq::Game
  alias PieceType = (Queen | Rook | Bishop | Knight | Pawn).class
  alias Material = Hash(PieceType, Int32)

  def material(side)
    pieces.select(&.side.== side).reject &.king?
  end

  def material
    {
      Side::Black => material(Side::Black).map(&.class).tally,
      Side::White => material(Side::White).map(&.class).tally,
    }
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
end
