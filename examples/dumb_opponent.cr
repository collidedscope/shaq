require "shaq"

class Shaq::Game
  # blindly chooses from the set of moves which leave the opponent with the least number of legal responses
  def best_move
    moves = legal_moves.map { |m| {m, sim(*m).ply.legal_moves.size} }
    moves.group_by(&.last).min[1].sample[0]
  end
end

game = Shaq::Game.new

get_move = uninitialized -> Nil
get_move = ->{
  print "Your move: "
  if move = gets
    game.ply move rescue get_move.call
  else
    game.ply *game.best_move
  end
}

loop do
  game.draw
  get_move.call
  resp = game.best_move
  puts "Computer move: #{game.algebraic_move *resp}"
  game.ply *resp
end
