module Shaq
  class Game
    START = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    TURN  = /\d+\.\s+(\S+)\s+(\S+)/

    def self.from_fen(fen)
      ranks, turn, castling, ep, hm_clock, move = fen.split

      board = ranks
        .delete('/')
        .gsub(/(\d)/) { "." * $1.to_i }
        .chars.map_with_index { |c, i|
        Piece.from_letter(c).tap &.position = i if c != '.'
      }
      turn = {b: Side::Black, w: Side::White}[turn]

      ep_target = Util.from_algebraic ep if ep != "-"
      game = new board, turn, castling, ep_target, hm_clock.to_i, move.to_i
      game.tap { |g| g.add_tag "FEN", fen unless fen == START }
    end

    def self.from_pgn(pgn)
      from_pgn_io IO::Memory.new pgn
    end

    def self.from_pgn_io(io)
      return nil unless io.peek.try &.first?

      new.tap do |game|
        while line = io.gets
          case line
          when /\[(\S+) "(.+?)"\]/
            game.add_tag $1, $2
          else
            # TODO: Preserve commentary?
            line.gsub(/{.+?}/, "").scan TURN do |(_, white, black)|
              game.ply white
              game.ply black unless black[/\d-/]?
            end

            break if io.peek.try &.first? == 91
          end
        end
      end
    end

    def self.from_pgn_file(path)
      File.open(path) { |f| from_pgn_io f }
    end

    def add_tag(key, value)
      tags[key] = value
    end

    def to_fen
      ranks = Util.fenalize board
      ep = ep_target ? Util.to_algebraic(ep_target.not_nil!) : '-'

      {ranks, black? ? 'b' : 'w', castling, ep, hm_clock, move}.join ' '
    end

    def to_pgn
      String.build do |s|
        tags.each do |key, value|
          s.puts %([#{key} "#{value}"])
        end

        s << '\n' unless tags.empty?

        s.puts history.each_slice(2).map_with_index(initial_move) { |move, i|
          "#{i}. #{move.join ' '}"
        }.join ' '
      end
    end
  end
end
