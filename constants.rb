require 'gosu_enhanced'

module Crossword
  # Constants for the crossword game
  module Constants
    include GosuEnhanced

    MARGIN      = 5

    BASE_WIDTH  = MARGIN * 2
    BASE_HEIGHT = MARGIN * 2

    GRID_ORIGIN = Point.new( MARGIN, MARGIN )

    CELL_SIZE   = Size.new( 28, 28 )

    WHITE       = Gosu::Color.new( 0xffffffff )
    BLACK       = Gosu::Color.new( 0xff000000 )
  end
end
