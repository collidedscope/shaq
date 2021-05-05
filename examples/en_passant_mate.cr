require "shaq"

# https://en.wikipedia.org/wiki/En_passant#Unusual_examples

game = Shaq::Game.from_fen "5B2/6p1/8/4RP1k/4pK1N/6P1/4qP2/8 b - - 0 1"
game.draw

game.ply "g5"
p game.checkmate?

game.ply "fxg6"
p game.checkmate?

p game.history
