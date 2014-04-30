#! /usr/bin/env ruby -I.

require 'gosu_enhanced'
require 'pp'

require 'constants'
require 'resources'
require 'puzloader'
require 'crosswordgrid'

module Crossword
  # Crossword!
  class Game < Gosu::Window
    include Constants

    attr_reader :font

    KEY_FUNCS = {
      Gosu::KbEscape  =>  -> { close },
      Gosu::KbTab     =>  -> { highlight_word( :next ) },
      Gosu::KbSpace   =>  -> { highlight_word( :swap ) }
    }

    def initialize( grid, title )
      @grid   = grid
      @width  = BASE_WIDTH + grid.width * CELL_SIZE.width
      @height = BASE_HEIGHT + grid.height * CELL_SIZE.height

      @down_left    = @width - (MARGIN * 2 + CLUE_COLUMN_WIDTH)
      @across_left  = @down_left - (MARGIN * 2 + CLUE_COLUMN_WIDTH)

      super( @width, @height, false, 100 )

      self.caption = "Ankh #{title}"

      @font = ResourceLoader.fonts( self )

      @highlighted_word, @word_cells, @current_cell = [], [], []
      highlight_word( :first, :across )
    end

    def needs_cursor?
      true
    end

    def update
    end

    def draw
      draw_background
      draw_grid
      draw_clues
    end

    def button_down( btn_id )
      instance_exec( &KEY_FUNCS[btn_id] ) if KEY_FUNCS.key? btn_id
    end

    private

    def highlight_word( number, direction = nil )
      direction ||= @highlighted[1]
      highlight_word_cells( false )

      number = @grid.first_clue( direction )    if number == :first
      number = @grid.next_clue( @highlighted[0], direction ) if number == :next
      
      if number == :swap
        direction = direction == :across ? :down : :across
        number    = @highlighted[0]
      end 

      @word_cells = @grid.word_cells( number, direction )

      highlight_word_cells

      @highlighted = [number, direction]
    end

    def highlight_word_cells( highlight = true )
      @word_cells.each do |row, col|
        @grid.cell_at( row, col ).highlighted = highlight
      end
    end

    def draw_background
      origin = Point.new( 0, 0 )
      size   = Size.new( @width, @height )
      draw_rectangle( origin, size, 0, WHITE )

      origin.move_by!( MARGIN, MARGIN )
      size.deflate!( MARGIN * 2, MARGIN * 2 )
      draw_rectangle( origin, size, 0, BLACK )
    end

    def draw_grid
      @grid.each_with_position do |cell, row, col|
        pos = GRID_ORIGIN.offset( col * CELL_SIZE.width, row * CELL_SIZE.height )
        draw_rectangle( pos, CELL_SIZE, 1, BLACK )
        draw_cell( pos, cell ) unless cell.blank?
      end
    end

    def draw_cell( pos, cell )
      bkgr = cell.highlighted ? HIGHLIGHT : WHITE
      draw_rectangle( pos.offset( 1, 1 ), CELL_SIZE.deflate( 2, 2 ), 1, bkgr )

      if cell.number != 0
        @font[:number].draw( cell.number, pos.x + 2, pos.y + 1, 1, 1, 1, BLACK )
      end

      unless cell.user.empty?
        lpos = pos.offset( @font[:cell].centred_in( cell.user, CELL_SIZE ) )
        @font[:cell].draw( cell.user, lpos.x, lpos.y + 1, 1, 1, 1, BLACK )
      end
    end

    def draw_clues
      across_point = Point.new( @across_left, MARGIN * 2 )
      down_point   = Point.new( @down_left, MARGIN * 2 )

      draw_clue_header( across_point, 'Across' )
      draw_clue_header( down_point, 'Down' )

      draw_clue_list( across_point, @grid.across_clues )
      draw_clue_list( down_point, @grid.down_clues )
    end

    def draw_clue_header( pos, header )
      @font[:header].draw( header, pos.x, pos.y, 1, 1, 1, WHITE )

      pos.move_by!( 0, @font[:header].height )
    end

    def draw_clue_list( pos, list )
      list.each { |clue| clue.draw( self, pos, CLUE_COLUMN_WIDTH ) }
    end
  end
end

filename = ARGV[0] || '2014-4-22-LosAngelesTimes.puz'
puz = PuzzleLoader.new( filename )

puts "Size:  #{puz.width} x #{puz.height}"
puts "Clues: #{puz.num_clues}"
puts 'Scrambled!' if puz.scrambled?

puts %(
Title:      #{puz.title}
Author:     #{puz.author}
Copyright:  #{puz.copyright}
)

cgrid = Crossword::Grid.new( puz.rows, puz.clues )

Crossword::Game.new( cgrid, puz.title ).show
