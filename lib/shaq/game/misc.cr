class Shaq::Game
  def occupancy
    board.each_with_index.sum { |e, i| (e ? 1u64 : 0u64) << i }
  end

  def occupied?(position)
    !!board[position]
  end

  def [](square)
    board[square.value]
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

  def shuffle!
    board.shuffle!.each_with_index do |piece, i|
      piece.try &.position = i
    end
  end
end
