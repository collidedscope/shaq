module Shaq
  class Game
    START = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

    def self.from_fen(fen)
      ranks, turn, castling, ep, hm_clock, move = fen.split

      board = ranks
        .delete('/')
        .gsub(/(\d)/) { "." * $1.to_i }
        .chars.map_with_index { |c, i|
        Piece.from_letter(c).tap &.position = i if c != '.'
      }

      turn = {b: Side::Black, w: Side::White}[turn]

      castling_squares = {'K' => 62, 'Q' => 58, 'k' => 6, 'q' => 2}
      castling = castling.chars.map(&->castling_squares.[]?(Char)).compact

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
            line.gsub(/({.+?}|(\(.+?\)))/, "").split do |ply|
              game.ply ply unless ply[0].ascii_number?
            end

            break if io.peek.try &.first? === '['
          end
        end
      end
    end

    def self.from_pgn_file(path)
      File.open(path) { |f| from_pgn_io f }.not_nil!
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

        result = tags["Result"]?
        result ||= if checkmate?
                     black? ? "1-0" : "0-1"
                   elsif draw?
                     "1/2-1/2"
                   end

        moves = history.each_slice 2
        movetext = moves.map_with_index(initial_move) { |move, i| "#{i}. #{move.join ' '}" }
        movetext << result if result
        s.puts movetext.join ' '
      end
    end
  end
end
