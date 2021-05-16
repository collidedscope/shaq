require "colorize"

def hex_to_rgb(hex)
  hex, b = hex.divmod 256
  hex, g = hex.divmod 256
  {hex.to_u8, g.to_u8, b.to_u8}
end

class Shaq::Game
  THEMES = {
    oxford: {0x192484, 0x4352db, 0x000000, 0xffffff},
    combat: {0x000000, 0xffffff, 0x0000ff, 0xff0000},
    coffee: {0x613a1c, 0xac6732, 0x000000, 0xffffff},
    purple: {0x4d4861, 0x605770, 0x221d23, 0xf7c4a5},
    ocean:  {0x005f73, 0x0a9396, 0x001219, 0xe9d8a6},
  }

  def draw(dark, light, black, white, flip = false)
    dark, light, black, white = {dark, light, black, white}.map { |color|
      Colorize::ColorRGB.new *hex_to_rgb color
    }

    (flip ? board.reverse : board).each_slice(8).with_index do |row, i|
      row.each_with_index do |piece, j|
        square = (i + j).odd? ? dark : light
        symbol = "#{piece.try(&.symbol) || ' '} "
        color = piece.try(&.white?) ? white : black
        print symbol.colorize(color).back square
      end
      puts
    end
  end

  def inspect(io)
    io << Util.fenalize(board).gsub(/(\d)/) { "." * $1.to_i }.tr("/", "\n")
  end

  def draw(theme = :oxford, flip = false)
    draw *THEMES[theme], flip
  end
end
