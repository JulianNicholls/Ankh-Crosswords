module Crossword
  # Show a completed window
  class CompleteOverlay
    include Constants

    def initialize( game )
      @game   = game
      @header = game.font[:o_title]
      @text   = game.font[:cell]

      @hdrsize = @header.measure( 'Complete' )
      
      @size     = Size.new( @hdrsize.width * 2, @hdrsize.height * 5 )
      @pos      = Point.new( (game.width - @size.width) / 2,
                             (game.height - @size.height) / 2 )

      @elapsed  = (Time.now - game.start_time)
    end

    def draw
      @game.draw_rectangle( @pos, @size, 5, HIGHLIGHT )
      @game.draw_rectangle( @pos.offset( MARGIN, MARGIN ), 
                            @size.deflate( MARGIN * 2, MARGIN * 2 ),
                            5, WHITE )
                           
      hpos = @pos.offset( (@size.width - @hdrsize.width) / 2, 
                          @hdrsize.height / 2 )

      @header.draw( 'Complete', hpos.x, hpos.y, 6, 1, 1, BLACK )
      time = format "Time: %d:%02d", @elapsed / 60, @elapsed % 60
      @text.draw( time, hpos.x, hpos.y + @hdrsize.height * 2, 6, 1, 1, BLACK )
      
    end
  end
end