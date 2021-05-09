class Shaq::Game
  def occupancy
    board.each_with_index.sum { |e, i| (e ? 1u64 : 0u64) << i }
  end
end
