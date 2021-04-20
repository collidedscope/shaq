require "shaq"

def mate_in_one(fen)
  game = Shaq::Game.from_fen fen
  game.legal_moves.each do |from, to|
    if game.sim(from, to).ply.checkmate?
      puts game.algebraic_move from, to
    end
  end
end

print "FEN: "
if fen = gets
  puts "Mates in one:"
  mate_in_one fen
end
