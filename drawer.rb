require 'constants'

module Crossword

  # Draw sections of the game  
  class Drawer
    include Constants
    
    def initialize( window )
      @window = window
    end
    
    def background
      origin = Point.new( 0, 0 )
      size   = Size.new( @window.width, @window.height )
      @window.draw_rectangle( origin, size, 0, WHITE )

      origin.move_by!( MARGIN, MARGIN )
      size.deflate!( MARGIN * 2, MARGIN * 2 )
      @window.draw_rectangle( origin, size, 0, BLACK )
    end
    
    def grid
      @window.grid.each_with_position do |cell, gpoint|
        pos = gpoint.to_point
        @window.draw_rectangle( pos, CELL_SIZE, 1, BLACK )
        draw_cell( pos, cell ) unless cell.blank?
      end      
    end

    private
    
    def draw_cell( pos, cell )
      bkgr = BK_COLOURS[cell.highlight]
      @window.draw_rectangle( pos.offset( 1, 1 ), CELL_SIZE.deflate( 2, 2 ), 1, bkgr )

      if cell.number != 0
        @window.font[:number].draw( cell.number, pos.x + 2, pos.y + 1, 1, 1, 1, BLACK )
      end

      unless cell.user.empty?
        lpos = pos.offset( @window.font[:cell].centred_in( cell.user, CELL_SIZE ) )
        @window.font[:cell].draw( cell.user, lpos.x, lpos.y + 1, 1, 1, 1, BLACK )
      end
    end
  end
end