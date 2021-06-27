module Shaq
  class MortalKingGame < Game
    variant "Mortal King"

    def no_king?
      friends.none? &.king?
    end

    def lost?
      no_king? || super
    end
  end
end
