class Shaq::Game
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
    material.transform_values { |tally| material_value tally }
  end
end
