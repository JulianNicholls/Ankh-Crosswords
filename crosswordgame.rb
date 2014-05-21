#! /usr/bin/env ruby -I.

require 'gosu_enhanced'
require 'pp'

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
      Gosu::KbSpace   =>  -> { @position = @current[0].to_point },

      Gosu::MsLeft    =>  -> { @position = Point.new( mouse_x, mouse_y ) }
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

      initial_highlight
    end

    def needs_cursor?
      true
    end

    def update
      update_cell unless @char.nil?
      update_current unless @position.nil?

      highlight_word
      highlight_current
    end
    
    def update_cell
      @grid.cell_at( @current[0] ).user = @char
      @char = nil
    end

    def update_current
      @cur_word.each { |gpoint| @grid.cell_at( gpoint ).highlight = :none }
      @grid.cell_at( @current[0] ).highlight = :none

      new_cur  = GridPoint.from_point( @position )
      new_word = @grid.word_from_pos( new_cur, @current[1] )

      unless new_word.empty?
        if new_cur == @current[0]
          @current[1] = @current[1] == :across ? :down : :across
          new_word = @grid.word_from_pos( new_cur, @current[1] )
        end

        @current[0], @cur_word = new_cur, new_word
      end

      @position = nil
    end

    def draw
      draw_background
      draw_grid
      draw_clues
    end

    def button_down( btn_id )
      instance_exec( &KEY_FUNCS[btn_id] ) if KEY_FUNCS.key? btn_id
      
      char = button_id_to_char( btn_id )
      @char = char.upcase unless char.nil? || !char.between?( 'a', 'z' )
    end

    private

    def initial_highlight
      number    = @grid.first_clue( :across )
      @cur_word = @grid.word_cells( number, :across )
      @current  = [@cur_word[0], :across]
    end

    def highlight_word
      @cur_word.each { |gpoint| @grid.cell_at( gpoint ).highlight = :word }
    end

    def highlight_current
      @grid.cell_at( @current[0] ).highlight = :current
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
      @grid.each_with_position do |cell, gpoint|
        pos = gpoint.to_point
        draw_rectangle( pos, CELL_SIZE, 1, BLACK )
        draw_cell( pos, cell ) unless cell.blank?
      end
    end

    def draw_cell( pos, cell )
      bkgr = BK_COLOURS[cell.highlight]
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

Crossword::Game.new( cgrid, "#{puz.title} - #{puz.author}" ).show
