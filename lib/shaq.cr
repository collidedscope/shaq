module Shaq
  enum Side
    Black; White
  end

  BACK_RANKS = {Side::White => 1, Side::Black => 8}
  PAWN_RANKS = {Side::White => 2, Side::Black => 7}
end

require "shaq/util"
require "shaq/game"
require "shaq/piece"
