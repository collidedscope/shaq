module Shaq
  class CloakDaggerGame < Game
    variant "Cloak and Dagger"

    def ply(from : Int32, to)
      super
      cloaks[other_side] = (piece = capture) && piece.turncloak! if real?
      self
    end
  end
end
