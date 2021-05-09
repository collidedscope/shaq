class Shaq::Game
  def occupancy
    board.each_with_index.sum { |e, i| (e ? 1u64 : 0u64) << i }
  end

  def opening
    tree = Shaq.opening_tree
    last_known = leaf = nil

    san_history.each do |move|
      last_known = leaf if leaf = tree[nil]?
      break unless trimmed = tree[move]?
      tree = trimmed
    end

    tree[nil]? || last_known
  end
end
