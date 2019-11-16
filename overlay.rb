module Crossword
  # Show a completed window
  class CompleteOverlay
    include Constants

    def initialize(game)
      @game   = game
      @header = game.font[:o_title]
      @text   = game.font[:cell]

      @hdrsize = @header.measure('Complete')

      @size     = Size(@hdrsize.width * 2, @hdrsize.height * 5)
      @pos      = Point((game.width - @size.width) / 2,
                        (game.height - @size.height) / 2)

      @elapsed  = (Time.now - game.start_time)
    end

    def draw
      draw_background
      draw_text
      draw_time
    end

    private

    def draw_background
      @game.draw_rectangle(@pos.offset(-10, -10), @size.inflate(20, 20),
                           5, SHADOW)

      @game.draw_rectangle(@pos, @size, 5, WHITE)

      @game.draw_rectangle(@pos.offset(1, 1), @size.deflate(2, 2),
                           5, CLUE_LIGHT)

      @game.draw_rectangle(@pos.offset(MARGIN, MARGIN),
                           @size.deflate(MARGIN * 2, MARGIN * 2), 5, HIGHLIGHT)
    end

    def draw_text
      hpos = @pos.offset((@size.width - @hdrsize.width) / 2,
                         @hdrsize.height / 2)

      @header.draw_text('Complete', hpos.x, hpos.y, 6, 1, 1, BLACK)
    end

    def draw_time
      hpos = @pos.offset((@size.width - @hdrsize.width) / 2,
                         @hdrsize.height * 5 / 2)
      time = format 'Time: %d:%02d', @elapsed / 60, @elapsed % 60
      @text.draw_text(time, hpos.x, hpos.y, 6, 1, 1, BLACK)
    end
  end
end
