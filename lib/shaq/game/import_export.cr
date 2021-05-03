module Shaq
  class Game
    START = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

    def self.from_fen(fen)
      ranks, turn, castling, ep_target, hm_clock, move = fen.split

      board = ranks
        .delete('/')
        .gsub(/(\d)/) { "." * $1.to_i }
        .chars.map_with_index { |c, i|
        Piece.from_letter(c).tap &.position = i if c != '.'
      }
      turn = {b: Side::Black, w: Side::White}[turn]

      game = new board, turn, castling, ep_target, hm_clock.to_i, move.to_i
      game.tap { |g| g.add_tag "FEN", fen unless fen == START }
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

    def add_tag(key, value)
      tags[key] = value
    end

    def to_pgn
      String.build do |s|
        tags.each do |key, value|
          s.puts %([#{key} "#{value}"])
        end

        s << '\n' unless tags.empty?

        s.puts history.each_slice(2).map_with_index(1) { |move, i|
          "#{i}. #{move.join ' '}"
        }.join ' '
      end
    end
  end
end
