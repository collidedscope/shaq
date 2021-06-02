require "compress/gzip"
require "yaml"

module Shaq
  enum Side
    Black
    White

    def other
      Side.new 1 - value
    end
  end

  enum Color
    Dark
    Light
  end

  enum Square
    {% for i in 0..63 %}
      {{"ABCDEFGH".chars[i % 8].id + "#{8 - i // 8}"}}
    {% end %}

    def color
      Color.new value.divmod(8).sum & 1
    end

    def rank
      8 - value // 8
    end

    def file
      'a' + value % 8
    end
  end

  enum Promotion
    QueenP  = 0
    KnightP = 1 << 6
    RookP   = 2 << 6
    BishopP = 3 << 6
  end

  def self.load_pgn(path)
    games = [] of Game

    File.open path do |io|
      while game = Game.from_pgn_io io
        games << game
      end
    end

    games
  end

  def self.load_pgn(path)
    File.open path do |io|
      while game = Game.from_pgn_io io
        yield game
      end
    end
  end

  OPENING_TREE = "#{__DIR__}/../data/opening_tree.yaml.gz"

  class_getter opening_tree : YAML::Any do
    Compress::Gzip::Reader.open OPENING_TREE, &->YAML.parse(IO)
  end
end

require "shaq/errors"
require "shaq/constants"
require "shaq/util"
require "shaq/game"
require "shaq/piece"
