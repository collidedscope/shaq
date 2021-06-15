module Shaq
  class KingoftheHillGame < Game
    variant "King of the Hill"

    def lost?
      enemy_king = enemies.find(&.king?).not_nil!
      super || {27, 28, 35, 36}.includes? enemy_king.position
    end
  end
end
