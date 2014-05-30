module Crossword
  # Have a clue.
  class Clue
    include Constants

    attr_reader :direction, :number, :text, :point, :region

    NUMBER_WIDTH = 21

    def self.from_text( line )
      dir, num, t, row, col = line.split ';'
      fail "Clue loading problem:\n##{t}#" if t[0] != '<' || t[-1] != '>'
      text = t[1..-2] # Remove <>

      new( dir.to_sym, num.to_i, text, GridPoint.new( row.to_i, col.to_i ) )
    end

    def initialize( direction, number, text, point, region = nil )
      @direction  = direction
      @number     = number
      @text       = text
      @point      = point
      @region     = region
    end

    def draw( game, pos, max_width, selected )
      size  = game.font[:clue].measure( text )
      tlc   = pos.dup

      game.font[:clue].draw( number, pos.x, pos.y, 2, 1, 1, WHITE )

      draw_wrapped( game, pos, text, (size.width / (max_width - NUMBER_WIDTH)).ceil )

      @region = Region.new( tlc, Size.new( max_width, pos.y - tlc.y ) )

      @region.draw( game, 1, CLUE_LIGHT ) if selected

      size.height + 1
    end

    def add_length( len )
      @text += " (#{len})"
    end

    def to_text
      base_text = text.sub( /\s+\(\d+\)$/, '' ) # Remove word length
      "#{direction};#{number};<#{base_text}>;#{point.row};#{point.col}"
    end

    private

    def draw_wrapped( game, pos, text, parts )
      wrap( text, parts ).each do |part|
        draw_simple( game, pos, part )
      end
    end

    def draw_simple( game, pos, text )
      font = game.font[:clue]

      font.draw( text, pos.x + NUMBER_WIDTH, pos.y, 2, 1, 1, WHITE )
      pos.move_by!( 0, font.height + 1 )
    end

    def wrap( text, pieces = 2 )
      return [text] if pieces == 1

      pos    = text.size / pieces

      # Find the next and previous spaces, and ...
      nspace = text.index( ' ', pos )
      pspace = text.rindex( ' ', pos )

      # ... split at the nearest one
      space = (nspace - pos).abs > (pspace - pos).abs ? pspace : nspace

      [text[0...space]] + wrap( text[space + 1..-1], pieces - 1 )
    end
  end
end
