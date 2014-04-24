require 'gosu_enhanced'

require './constants'
require './puzloader'
require './crosswordgrid'

module Crossword
  # Crossword!
  class Game < Gosu::Window
    include Constants

    def initialize( grid )
      @grid   = grid
      @width  = BASE_WIDTH + grid.width * CELL_SIZE.width
      @height = BASE_HEIGHT + grid.height * CELL_SIZE.height

      super( @width, @height, false, 100 )

      self.caption = 'Crosswords'

      @cell_font    = Gosu::Font.new( self, 'Arial', 14 )
      @number_font  = Gosu::Font.new( self, 'Arial', 9 )
      @clue_font    = Gosu::Font.new( self, 'Arial', 14 )
    end

    def needs_cursor?
      true
    end

    def update

    end

    def draw
      draw_background
      draw_grid
    end
    
    def button_down( btn_id )
      close if btn_id == Gosu::KbEscape
    end

    private

    def draw_background
      origin = Point.new( 0, 0 )
      size   = Size.new( @width, @height )
      draw_rectangle( origin, size, 0, WHITE )

      origin.move_by!( MARGIN, MARGIN )
      size.deflate!( MARGIN * 2, MARGIN * 2 )
      draw_rectangle( origin, size, 0, BLACK )
    end

    def draw_grid
      @grid.height.times do |row|
        pos = GRID_ORIGIN.offset( 0, row * CELL_SIZE.height )

        @grid.width.times do |col|
          draw_rectangle( pos, CELL_SIZE, 1, BLACK )
          cell = @grid.cell_at( row, col )
          draw_cell( pos.dup, cell ) unless cell.blank?

          pos.move_by!( CELL_SIZE.width, 0 )
        end
      end
    end

    def draw_cell( pos, cell )
      draw_rectangle( pos.offset( 1, 1 ), CELL_SIZE.deflate( 2, 2 ), 1, WHITE )

      if cell.number != 0
        @number_font.draw( cell.number, pos.x + 3, pos.y + 2, 1, 1, 1, BLACK )
      end

      unless cell.user.empty?
        pos.move_by!( @cell_font.centred_in( letter, CELL_SIZE ) )
        @cell_font.draw( cell.user, pos.x, pos.y, 1, 1, 1, BLACK )
      end
    end
  end
end

puz = PuzzleLoader.new( '2014-4-22-LosAngelesTimes.puz' )

puts "Size:  #{puz.width} x #{puz.height}"
puts "Clues: #{puz.num_clues}"
puts 'Scrambled!' if puz.scrambled?

puts %(
Title:      #{puz.title}
Author:     #{puz.author}
Copyright:  #{puz.copyright}
)

cgrid = CrosswordGrid.new( puz.rows, puz.clues )

Crossword::Game.new( cgrid ).show
