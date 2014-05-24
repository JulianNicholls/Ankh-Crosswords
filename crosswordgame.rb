#! /usr/bin/env ruby -I.

require 'gosu_enhanced'
require 'pp'

require 'resources'
require 'puzloader'
require 'grid'
require 'drawer'

module Crossword
  # Crossword!
  class Game < Gosu::Window
    include Constants

    attr_reader :width, :height, :font, :grid

    KEY_FUNCS = {
      Gosu::KbEscape  =>  -> { close },
      Gosu::KbSpace   =>  -> { @position = @current.gpos },
      Gosu::KbTab     =>  -> { next_clue },

      Gosu::KbDown    =>  -> { @position = @grid.cell_down( @current.gpos ) },
      Gosu::KbUp      =>  -> { @position = @grid.cell_up( @current.gpos ) },
      Gosu::KbLeft    =>  -> { @position = @grid.cell_left( @current.gpos ) },
      Gosu::KbRight   =>  -> { @position = @grid.cell_right( @current.gpos ) },

      Gosu::MsLeft    =>  -> { @position = GridPoint.from_xy( mouse_x, mouse_y ) }
    }

    def initialize( grid, title )
      @grid   = grid
      @width  = BASE_WIDTH + grid.width * CELL_SIZE.width
      @height = BASE_HEIGHT + grid.height * CELL_SIZE.height

      super( @width, @height, false, 100 )

      self.caption = "Ankh #{title}"

      @down_left    = @width - (MARGIN * 2 + CLUE_COLUMN_WIDTH)
      @across_left  = @down_left - (MARGIN * 2 + CLUE_COLUMN_WIDTH)

      @font   = ResourceLoader.fonts( self )
      @drawer = Drawer.new( self )

      initial_highlight
    end

    def needs_cursor?
      true
    end

    def update
      update_cell    unless @char.nil?
      update_current unless @position.nil?

      highlight_word
      highlight_current
    end

    def draw
      @drawer.background
      @drawer.grid
      draw_clues
    end

    def button_down( btn_id )
      instance_exec( &KEY_FUNCS[btn_id] ) if KEY_FUNCS.key? btn_id

      char = button_id_to_char( btn_id )
      @char = char.upcase unless char.nil? || !char.between?( 'a', 'z' )
      @char = '' if btn_id == Gosu::KbBackspace
    end

    private

    def initial_highlight
      number    = @grid.first_clue( :across )
      cur_word  = @grid.word_cells( number, :across )
      @current  = CurrentState.new( cur_word[0], number, :across )
    end

    def highlight_word
      cells = @grid.word_cells( @current.number, @current.dir )
      cells.each { |gpoint| @grid.cell_at( gpoint ).highlight = :word }
    end

    def highlight_current
      @grid.cell_at( @current.gpos ).highlight = :current
    end

    def unhighlight
      cells = @grid.word_cells( @current.number, @current.dir )
      cells.each { |gpoint| @grid.cell_at( gpoint ).highlight = :none }
      @grid.cell_at( @current.gpos ).highlight = :none
    end

    def update_cell
      unhighlight

      if @char.empty?
        cell_empty = @grid.cell_at( @current.gpos ).user.empty?
        @grid.prev_word_cell( @current ) if cell_empty
        @grid.cell_at( @current.gpos ).user = ''
        @grid.prev_word_cell( @current ) unless cell_empty
      else
        @grid.cell_at( @current.gpos ).user = @char

        @grid.next_word_cell( @current )
      end

      @char = nil
    end

    def update_current
      unhighlight

      new_num  = @grid.word_num_from_pos( @position, @current.dir )

      unless new_num == 0
        if @position == @current.gpos  # Click on current == swap direction
          @current.swap_direction
          new_num = @grid.word_num_from_pos( @position, @current.dir )
        end

        @current.gpos, @current.number = @position, new_num
      end

      @position = nil
    end

    def next_clue
      unhighlight

      @current.number = @grid.next_clue( @current.number, @current.dir )
      @current.gpos   = @grid.word_cells( @current.number, @current.dir )[0]
    end

    def draw_clues
      across_point = Point.new( @across_left, MARGIN * 2 )
      down_point   = Point.new( @down_left, MARGIN * 2 )

      draw_clue_header( across_point, 'Across' )
      draw_clue_header( down_point, 'Down' )

      draw_clue_list_with_current( across_point, @grid.across_clues,
                                   @current.dir == :across )
      draw_clue_list_with_current( down_point, @grid.down_clues,
                                   @current.dir == :down )
    end

    def draw_clue_header( pos, header )
      @font[:header].draw( header, pos.x, pos.y, 1, 1, 1, WHITE )

      pos.move_by!( 0, @font[:header].height )
    end

    # Render the clue list off screen first, then redraw it where asked,
    # potentially not from the start if the current clue wouldn't be displayed
    def draw_clue_list_with_current( pos, list, current_list )
      off_screen = pos.offset( width, 0 )
      skip =  draw_clue_list( off_screen, list, current_list )
      draw_clue_list( pos, list[skip..-1], current_list )
    end

    # Draw the list of clues, ensuring that the current one is on screen
    def draw_clue_list( pos, list, current_list )
      found = !current_list # Not current, found OK. Current, still looking
      shown = 0

      list.each do |clue|
        is_current = current_list && @current.number == clue.number
        found ||= is_current

        lh = clue.draw( self, pos, CLUE_COLUMN_WIDTH, is_current )
        shown += 1

        break if pos.y >= height - (MARGIN + lh)
      end

      current_list && !found ? (list.size - shown) : 0
    end
  end

  # Hold the current state: The cell position, and word number and direction
  # that it's a part of.
  class CurrentState < Struct.new( :gpos, :number, :dir )
    def swap_direction
      self.dir = dir == :across ? :down : :across
    end

    def new_word( clue_number, pos )
      self.number, self.gpos = clue_number, pos
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
