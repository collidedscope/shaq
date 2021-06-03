module Shaq
  class ExtinctionGame < Game
    variant "Extinction"

    def check?
      false
    end

    def checkmate?
      friends.map(&.type).uniq.size < 6
    end
  end
end
