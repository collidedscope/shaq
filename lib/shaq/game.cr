require "shaq/game/algebraic"
require "shaq/game/import_export"

module Shaq
  class Game
    PIECES  = {R: Rook, N: Knight, B: Bishop, Q: Queen, K: King}
    LETTERS = PIECES.to_h.invert

    property \
      board : Array(Piece?),
      turn : Side,
      castling : String,
      ep_target : Int32?,
      hm_clock : Int32,
      move : Int32,
      history = [] of String,
      tags = {} of String => String

    def initialize(@board, @turn, @castling, @ep_target, @hm_clock, @move)
    end

    def self.new
      from_fen START
    end

    def sim(from, to)
      clone.ply from, to, false
    end

    def legal_moves_for(piece)
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
      raise "No piece at #{from}!" unless piece = board[from]
      raise "Illegal move: #{from}->#{to}" unless !real || can_move? piece, to

      board[to + (white? ? 8 : -8)] = nil if piece.pawn? && to == @ep_target
      @ep_target = nil

      if piece.pawn?
        @ep_target = to + (white? ? 8 : -8) if (from - to).abs == 16

        if Util.rank(to % 64) == BACK_RANKS[other_side]
          promo, to = to.divmod 64
          piece = {Queen, Knight, Rook, Bishop}[promo].new turn
        end
      end

      if real
        history << algebraic_move from, (promo || 0) << 6 | to
        ply
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
        type = PIECES[mover[0, 1]]? || Pawn
        # TODO: Figure out why friends.select(type) doesn't work.

        candidates = friends(type)
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
      return false unless check?

      king = friends.find(&.king?).not_nil!
      return false unless legal_moves_for(king).empty?

      friends.each do |ally|
        legal_moves_for(ally).each do |square|
          return false unless sim(ally.position, square).check?
        end
      end

      true
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

    def friends
      board.select(Piece).select &.side.== turn
    end

    def friends(piece)
      friends.select &.class.== piece
    end

    def enemies
      board.select(Piece).select &.side.!= turn
    end

    def enemies(piece)
      enemies.select &.class.== piece
    end

    def clone
      dup.tap &.board = board.map &.dup
    end

    def draw
      @board.each_slice 8 do |row|
        p row
      end
    end
  end
end
