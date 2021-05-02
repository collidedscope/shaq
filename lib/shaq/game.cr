module Shaq
  class Game
    START   = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    PIECES  = {R: Rook, N: Knight, B: Bishop, Q: Queen, K: King}
    LETTERS = PIECES.to_h.invert

    property \
      board : Array(Piece?),
      turn : Side,
      castling : String,
      ep_target : String,
      hm_clock : Int32,
      move : Int32,
      history = [] of String,
      tags = {} of String => String

    def initialize(@board, @turn, @castling, @ep_target, @hm_clock, @move)
    end

    def add_tag(key, value)
      tags[key] = value
    end

    def self.from_fen(fen)
      ranks, turn, castling, ep_target, hm_clock, move = fen.split

      board = ranks
        .delete('/')
        .gsub(/(\d)/) { "." * $1.to_i }
        .chars.map_with_index { |c, i|
        Piece.from_letter(c).tap &.position = i if c != '.'
      }
      turn = {b: Side::Black, w: Side::White}[turn]

      new board, turn, castling, ep_target, hm_clock.to_i, move.to_i
    end

    def self.from_pgn(pgn)
      from_pgn_io IO::Memory.new pgn
    end

    def self.from_pgn_io(io)
      new.tap do |game|
        while line = io.gets
          case line
          when /\[(\S+) "(.+?)"\]/
            game.add_tag $1, $2
          else
            line.scan /\d+\. (\S+) (\S+)/ do |(_, white, black)|
              game.ply white
              game.ply black unless black[/\d-/]?
            end
          end
        end
      end
    end

    def self.from_pgn_file(path)
      File.open(path) { |f| from_pgn_io f }
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
      raise "Illegal move (#{from}->#{to})" unless !real || can_move? piece, to

      if piece.pawn? && Util.rank(to % 64) == BACK_RANKS[other_side]
        promo, to = to.divmod 64
        piece = {Queen, Knight, Rook, Bishop}[promo].new turn
      end

      if real
        history << algebraic_move from, to
        ply
      end

      tap { board[from], board[to] = nil, piece.tap &.position = to }
    end

    # TODO: Handle castling and promotion.
    def ply(san)
      rank = file = nil

      if square = san[/^(#{SQUARE})/]?
        piece = friends(Pawn).find { |p| can_move? p, square }
      elsif move = san.match /(.+?)x?(#{SQUARE})/
        _, mover, square = move
        type = PIECES[mover[0, 1]]? || Pawn
        # TODO: Figure out why friends.select(type) doesn't work.

        candidates = friends(type)
        candidates.select! &.rank.== rank.to_i if rank = mover[/[1-8]/]?
        candidates.select! &.file.== file[0] if file = mover[/[a-h]/]?

        piece = candidates.find { |c| can_move? c, square }
      end

      raise "Weird move: #{san}" unless piece && square

      ply piece.position, Util.from_algebraic square
    end

    def check?
      if king = friends.find &.king?
        vision = enemies.flat_map &.vision self
        vision.includes? king.position
      else
        raise "No #{turn} King?!"
      end
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

    # TODO: Handle castling and promotion.
    def algebraic_move(from, to)
      raise "No piece at #{from}!" unless piece = board[from]

      String.build do |s|
        case piece
        when Pawn
          s << Util.file from if board[to]
        else
          s << algebraic_piece piece, to
        end

        s << 'x' if board[to]
        s << Util.to_algebraic to

        g = sim(from, to).ply
        if g.checkmate?
          s << '#'
        elsif g.check?
          s << '+'
        end
      end
    end

    def algebraic_piece(piece, target)
      String.build do |s|
        s << LETTERS[piece.class]
        candidates = friends piece.class
        candidates.select! { |c| legal_moves_for(c).includes? target }
        next if candidates.size == 1

        if candidates.count(&.file.== piece.file) == 1
          s << piece.file
        elsif candidates.count(&.rank.== piece.rank) == 1
          s << piece.rank
        else
          s << piece.file << piece.rank
        end
      end
    end

    def draw
      @board.each_slice 8 do |row|
        p row
      end
    end
  end
end
