module Shaq
  class Game
    def self.from_fen(fen)
      fields = fen.split
      raise InvalidFenError.new "need exactly 6 fields" unless fields.size == 6
      ranks, side, castling, ep, hm_clock, move = fields

      if bad = ranks.chars.find &.in_set? "^PRNBQKprnbqk/1-8"
        raise InvalidFenError.new "'#{bad}' in ranks"
      end

      board = ranks
        .delete('/')
        .gsub(/(\d)/) { "." * $1.to_i }
        .chars.map_with_index &->Piece.from_letter(Char, Int32)

      raise InvalidFenError.new "need exactly 64 squares" unless board.size == 64

      unless turn = {b: Side::Black, w: Side::White}[side]?
        raise InvalidFenError.new "side must be 'b' or 'w', not '#{side}'"
      end

      castling_squares = {'K' => 62, 'Q' => 58, 'k' => 6, 'q' => 2}
      castling = castling.chars.map(&->castling_squares.[]?(Char)).compact

      ep_target = Util.from_algebraic ep if ep != "-"

      game = new board, turn, castling, ep_target, hm_clock.to_i, move.to_i
      raise "Illegal position: King can be taken" if game.ply.check?
      game.ply.tap { |g| g.add_tag "FEN", fen unless fen == STANDARD }
    end

    def self.from_diagram(diagram)
      lines = diagram.lines
      fields = lines.shift
      board = lines[...-1].flat_map &.split[1..]

      unchecked_from_fen \
        board.map_with_index { |c, i| Piece.from_letter c[0], i },
        fields
    end

    def self.unchecked_from_fen(board, fields)
      side, castling, ep, hm_clock, move = fields.split
      turn = {b: Side::Black, w: Side::White}[side]
      castling_squares = {'K' => 62, 'Q' => 58, 'k' => 6, 'q' => 2}
      castling = castling.chars.map(&->castling_squares.[]?(Char)).compact
      ep_target = Util.from_algebraic ep if ep != "-"
      new board, turn, castling, ep_target, hm_clock.to_i, move.to_i
    end

    def self.from_pgn(pgn)
      from_pgn_io IO::Memory.new pgn
    end

    def self.from_pgn_io(io)
      return nil unless io.peek.try &.first?

      game = nil
      tags = {} of String => String

      while line = io.gets
        next tags[$1] = $2 if line.match /\[(\S+) "(.+?)"\]/

        game ||= from_tags tags

        # TODO: Preserve commentary?
        line.gsub(/({.+?}|(\(.+?\)))/, "").split do |ply|
          game.ply ply unless ply[0].ascii_number? || ply == "*"
        end
        break if io.peek.try &.first? === '['
      end

      game
    end

    def self.from_tags(tags)
      type = case tags["Variant"]?
             when "Antichess"   ; AntichessGame
             when "Atomic"      ; AtomicGame
             when "Horde"       ; HordeGame
             when "Racing Kings"; RacingKingsGame
             else                 Game
             end

      if fen = tags["FEN"]?
        type.from_fen fen
      else
        type.new
      end.tap &.tags = tags
    end

    def self.from_pgn_file(path)
      File.open(path) { |f| from_pgn_io f }.not_nil!
    end

    def add_tag(key, value)
      tags[key] = value
    end

    def to_fen
      ranks = Util.fenalize board
      ep = Util.to_algebraic ep_target

      {ranks, black? ? 'b' : 'w', castling, ep, hm_clock, move}.join ' '
    end

    def to_pgn(ignore_spec = false)
      roster = %i[Event Site Date Round White Black Result]

      String.build do |s|
        # Prioritize the Seven Tag Roster per the PGN specification.
        roster.each do |tag|
          if value = tags[tag]?
            s.puts %([#{tag} "#{value}"])
          else
            s.puts %([#{tag} "?"]) unless ignore_spec
          end
        end

        tags.each do |tag, value|
          s.puts %([#{tag} "#{value}"]) unless roster.includes? tag
        end

        s << '\n' unless tags.empty?

        result = tags["Result"]?
        result ||= if checkmate?
                     black? ? "1-0" : "0-1"
                   elsif draw?
                     "1/2-1/2"
                   end

        moves = san_history.each_slice 2
        movetext = moves.map_with_index(initial_move) { |move, i| "#{i}. #{move.join ' '}" }
        movetext << result if result
        s.puts movetext.join ' '
      end
    end
  end
end
