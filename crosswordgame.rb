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
      Gosu::KbEscape  =>  -> { close if @complete },
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

      @font       = ResourceLoader.fonts( self )
      @drawer     = Drawer.new( self )
      @help_mode  = false
      @start_time = Time.now
      @complete   = false

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
      @drawer.clues( @current )
    end

    def button_down( btn_id )
      instance_exec( &KEY_FUNCS[btn_id] ) if KEY_FUNCS.key? btn_id

      char = button_id_to_char( btn_id )
      @char = char.upcase unless char.nil? || !char.between?( 'a', 'z' )
      @char = '' if btn_id == Gosu::KbBackspace
    end

    private

    def current_cell
      @grid.cell_at( @current.gpos )
    end

    def initial_highlight
      number    = @grid.first_clue( :across )
      cur_word  = @grid.word_cells( number, :across )
      @current  = CurrentState.new( cur_word[0], number, :across )
    end

    def highlight_word
      cells = @grid.word_cells( @current.number, @current.dir )
      cells.each do |gpoint|
        cell = @grid.cell_at( gpoint )
        cell.highlight = :word if cell.highlight != :wrong
      end
    end

    def highlight_current
      current_cell.highlight = :current if current_cell.highlight != :wrong
    end

    def unhighlight
      cells = @grid.word_cells( @current.number, @current.dir )
      cells.each do |gpoint|
        cell = @grid.cell_at( gpoint )
        cell.highlight = :none if cell.highlight != :wrong
      end

      current_cell.highlight = :none if current_cell.highlight != :wrong
    end

    def update_cell
      unhighlight

      if @char.empty?
        empty_cell
      else
        current_cell.user = @char
        current_cell.highlight =
          @help_mode && current_cell.letter != current_cell.user ? :wrong : :none
        @grid.next_word_cell( @current )
      end

      @char = nil
    end

    def empty_cell
      cell_empty = current_cell.user.empty?
      @grid.prev_word_cell( @current ) if cell_empty
      current_cell.user = ''
      current_cell.highlight = :none
      @grid.prev_word_cell( @current ) unless cell_empty
    end

    def update_current
      unhighlight

      return current_from_clue if @position.out_of_range?( @grid )

      current_from_cell

      @position = nil
    end

    def current_from_clue
      mouse_pos = Point.new( mouse_x, mouse_y )

      @grid.clues.each do |clue|
        next if clue.region.nil?

        if clue.region.contains?( mouse_pos )
          @current = CurrentState.from_clue( clue, grid )
          break
        end
      end

      @position = nil
    end

    def current_from_cell
      new_num  = @grid.word_num_from_pos( @position, @current.dir )

      unless new_num == 0   # Blank square, most likely
        if @position == @current.gpos  # Click on current == swap direction
          @current.swap_direction
          new_num = @grid.word_num_from_pos( @position, @current.dir )
        end

        @current.gpos, @current.number = @position, new_num
      end
    end

    def next_clue
      unhighlight

      number = @grid.next_clue( @current.number, @current.dir )
      @current.new_word( number, @grid.cell_pos( number, @current.dir ) )
    end
  end

  # Hold the current state: The cell position, and word number and direction
  # that it's a part of.
  class CurrentState < Struct.new( :gpos, :number, :dir )
    def self.from_clue( clue, grid )
      new(
        grid.cell_pos( clue.number, clue.direction ),
        clue.number,
        clue.direction
      )
    end

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

# puts "Size:  #{puz.width} x #{puz.height}"
# puts "Clues: #{puz.num_clues}"
# puts 'Scrambled!' if puz.scrambled?
#
# puts %(
# Title:      #{puz.title}
# Author:     #{puz.author}
# Copyright:  #{puz.copyright}
# )

cgrid = Crossword::Grid.new( puz.rows, puz.clues )

Crossword::Game.new( cgrid, "#{puz.title} - #{puz.author}" ).show
