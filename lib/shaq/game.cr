module Shaq
  class Game
    START = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

    property \
      board : Array(Piece?),
      turn : Side,
      castling : String,
      ep_target : String,
      hm_clock : Int32,
      move : Int32,
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

    def ply
      tap { @turn = turn == Side::Black ? Side::White : Side::Black }
    end

    def ply(from, to, checked = true)
      if piece = board[from]
        unless !checked || legal_moves_for(piece).includes? to
          raise "Illegal move (#{from}->#{to})"
        end
        ply if checked
        tap { board[from], board[to] = nil, piece.tap &.position = to }
      else
        raise "No piece at #{from}!"
      end
    end

    def ply(san)
      # TODO: Parse SAN moves
    end

    def check?
      if king = friends.find &.is_a? King
        vision = enemies.flat_map &.vision self
        vision.includes? king.position
      else
        raise "No #{turn} King?!"
      end
    end

    def checkmate?
      return false unless check?

      king = friends.find(&.is_a? King).not_nil!
      return false unless legal_moves_for(king).empty?

      friends.each do |ally|
        legal_moves_for(ally).each do |square|
          return false unless sim(ally.position, square).check?
        end
      end

      true
    end

    def friends
      board.select(Piece).select &.side.== turn
    end

    def enemies
      board.select(Piece).select &.side.!= turn
    end

    def clone
      dup.tap &.board = board.map &.dup
    end

    # TODO: handle disambiguation
    def algebraic_move(from, to)
      raise "No piece at #{from}!" unless piece = board[from]

      String.build do |s|
        case piece
        when Pawn
          s << Util.file from if board[to]
        else
          # TODO: always capital
          piece.inspect s
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

    def draw
      @board.each_slice 8 do |row|
        p row
      end
    end
  end
end
