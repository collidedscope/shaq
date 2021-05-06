require "colorize"

class Shaq::Game
  def draw(dark = 25, light = 69, black = 16, white = 255, flip = false)
    dark, light, black, white = {dark, light, black, white}.map { |color|
      Colorize::Color256.new color.to_u8
    }

    (flip ? board.reverse : board).each_slice(8).with_index do |row, i|
      row.each_with_index do |piece, j|
        square = (i + j).odd? ? dark : light
        symbol = "#{piece.try(&.symbol) || ' '} "
        color = piece.try(&.white?) ? white : black
        print symbol.colorize(color).back square
      end
      puts
    end
  end
end
