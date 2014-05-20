
module Crossword
  # Have a clue.
  class Clue
    include Constants

    attr_reader :direction, :number, :text, :point, :region

    def initialize( direction, number, text, point, region = nil )
      @direction  = direction
      @number     = number
      @text       = text
      @point      = point
      @region     = region
    end

    def draw( game, pos, max_width )
      font = game.font[:clue]

      size  = font.measure( text )
      tlc   = pos

      font.draw( number, pos.x, pos.y, 1, 1, 1, WHITE )

      if size.width > max_width
        draw_wrapped( game, pos, text, (size.width / max_width).ceil )
      else
        draw_simple( game, pos, text )
      end

      @region = Region.new( tlc, Size.new( CLUE_COLUMN_WIDTH, pos.y - tlc.y ) )
    end

    private

    def draw_wrapped( game, pos, text, parts )
      wrap( text, parts ).each do |part|
        draw_simple( game, pos, part )
      end
    end

    def draw_simple( game, pos, text )
      font = game.font[:clue]

      font.draw( text, pos.x + 18, pos.y, 1, 1, 1, WHITE )
      pos.move_by!( 0, font.height )
    end

    def wrap( text, pieces = 2 )
      return [text] if pieces == 1

      pos    = text.size / pieces
      nspace = text.index( ' ', pos )
      pspace = text.rindex( ' ', pos )

      space = (nspace - pos).abs > (pspace - pos).abs ? pspace : nspace

      [text[0...space]] + wrap( text[space + 1..-1], pieces - 1 )
    end
  end
end
