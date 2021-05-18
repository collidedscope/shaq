class Shaq::Game
  def material(side)
    pieces(side).map &.type
  end

  def material
    {Side::Black, Side::White}.map { |side| {side, material(side).tally} }.to_h
  end

  def material_value(material)
    material.sum { |piece, amount| VALUES[piece.to_s] * amount }
  end

  def material_value
    material.transform_values &->material_value(Material)
  end

  def material_imbalance
    black, white = material.values
    imbalance = {Side::Black => Material.new, Side::White => Material.new}

    Piece::Type.each do |piece|
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
