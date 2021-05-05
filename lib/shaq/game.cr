require "shaq/game/algebraic"
require "shaq/game/draw"
require "shaq/game/import_export"
require "shaq/game/material"

module Shaq
  class Game
    PIECES = {P: Pawn, R: Rook, N: Knight, B: Bishop, Q: Queen, K: King}

    property \
      board : Array(Piece?),
      turn : Side,
      castling : String,
      ep_target : Int32?,
      hm_clock : Int32,
      move : Int32,
      initial_move : Int32,
      history = [] of String,
      positions = Hash(String, Int32).new(0),
      tags = {} of String => String

    def initialize(@board, @turn, @castling, @ep_target, @hm_clock, @move)
      @initial_move = move
      history << "..." if black?
    end

    def self.new
      from_fen START
    end

    def sim(from, to)
      clone.ply from, to, false
    end

    def legal_moves_for(piece) : Array(Int32)
      piece.moves(self).reject { |square| sim(piece.position, square).check? }
    end

    def legal_moves
      friends.flat_map { |piece|
        legal_moves_for(piece).map { |move| {piece.position, move} }
      }
    end

    def can_move?(piece, square)
      legal_moves_for(piece).includes? square
    end

    def can_move?(piece, square : String)
      can_move? piece, Util.from_algebraic square
    end

    def ply
      tap { @turn = other_side }
    end

    def ply(from, to, real = true)
      raise "Game is over!" if real && over?
      raise "No piece at #{from}!" unless piece = board[from]
      raise "Illegal move: #{from}->#{to}" unless !real || can_move? piece, to

      board.swap to, to + (white? ? 8 : -8) if piece.pawn? && to == @ep_target
      @ep_target = nil

      if piece.pawn?
        @ep_target = to + (white? ? 8 : -8) if (from - to).abs == 16

        if Util.rank(to % 64) == BACK_RANKS[other_side]
          promo, to = to.divmod 64
          piece = {Queen, Knight, Rook, Bishop}[promo].new turn
        end
      end

      irreversible = piece.pawn? || board[to]

      if real
        history << algebraic_move from, (promo || 0) << 6 | to
        @hm_clock = irreversible ? 0 : hm_clock + 1
        @move += 1 if black?
        ply

        # TODO: take other factors into account (castling, en passant, turn)
        positions[Util.fenalize board] += 1 unless irreversible
      end

      tap { board[from], board[to] = nil, piece.tap &.position = to }
    end

    # TODO: Handle castling.
    def ply(san)
      rank = file = nil

      if square = san[/^([a-h][1-8])/]?
        piece = friends(Pawn).find { |p| can_move? p, square }
      elsif move = san.match /(.+?)x?([a-h][1-8])/
        _, mover, square = move

        candidates = friends PIECES[mover[0, 1]]? || Pawn
        candidates.select! &.rank.== rank.to_i if rank = mover[/[1-8]/]?
        candidates.select! &.file.== file[0] if file = mover[/[a-h]/]?

        piece = candidates.find { |c| can_move? c, square }
      end

      raise "Invalid or illegal move: #{san}" unless piece && square

      target = Util.from_algebraic square
      target |= "QNRB".index($1).not_nil! << 6 if san.match(/=([QNRB])/)
      ply piece.position, target
    end

    def check?
      raise "No #{turn} King?!" unless king = friends.find &.king?
      enemies.flat_map(&.vision self).includes? king.position
    end

    def checkmate?
      check? && legal_moves.empty?
    end

    def stalemate?
      legal_moves.empty? && !check?
    end

    def insufficient_material?
      pieces.all? &.king?
    end

    def repetition?(n = 3)
      positions.any? &.[1].>= n
    end

    def draw?
      repetition? || stalemate? || insufficient_material? || hm_clock >= 100
    end

    def over?
      draw? || checkmate? || stalemate?
    end

    def black?
      turn == Side::Black
    end

    def white?
      !black?
    end

    def other_side
      turn == Side::Black ? Side::White : Side::Black
    end

    def pieces
      board.select Piece
    end

    def friends
      pieces.select &.side.== turn
    end

    def friends(piece)
      friends.select &.class.== piece
    end

    def enemies
      pieces.select &.side.!= turn
    end

    def enemies(piece)
      enemies.select &.class.== piece
    end

    def occupancy
      board.each_with_index.sum { |e, i| (e ? 1u64 : 0u64) << i }
    end

    def clone
      dup.tap &.board = board.map &.dup
    end
  end
end
