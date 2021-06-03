module Shaq
  class ExtinctionGame < Game
    variant "Extinction"

    def check?
      false
    end

    def checkmate?
      if friends.uniq(&.type).size == 6
        false
      elsif enemies.uniq(&.type).size < 6
        capture.not_nil!.side == turn
      else
        true
      end
    end
  end
end
