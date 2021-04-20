require "shaq"

def mate_in_one(game)
  if mate = game.legal_moves.find { |move| game.sim(*move).ply.checkmate? }
    game.algebraic_move *mate
  end
end

print "FEN: "
if fen = gets
  game = Shaq::Game.from_fen fen
  puts "Mate in one:", mate_in_one game
end
