#! /usr/bin/env ruby -I.

require 'gosu_enhanced'
require 'pp'

require 'resources'
require 'puzloader'
require 'grid'
require 'drawer'
require 'gamerepo'
require 'overlay'
require 'state'

module Crossword
  # Crossword!
  class Puzzle < Gosu::Window
    include Constants

    attr_reader :width, :height, :font, :image, :grid, :start_time

    KEY_FUNCS = {
      Gosu::KbEscape  =>  -> { handle_escape },
      Gosu::KbTab     =>  -> { handle_tab },
      Gosu::KbF1      =>  -> { @help_mode = !@help_mode },

      Gosu::KbDown    =>  -> { @position = @grid.cell_down(@current.gpos) },
      Gosu::KbUp      =>  -> { @position = @grid.cell_up(@current.gpos) },
      Gosu::KbLeft    =>  -> { @position = @grid.cell_left(@current.gpos) },
      Gosu::KbRight   =>  -> { @position = @grid.cell_right(@current.gpos) },

      Gosu::KbSpace   =>  -> { @position = @current.gpos },

      Gosu::MsLeft    =>  -> { @position = GridPoint.from_xy(mouse_x, mouse_y) }
    }

    def initialize(filename)
      @game   = GameRepository.load(filename)
      @grid   = @game.grid
      @width  = BASE_WIDTH + grid.size.width
      @height = BASE_HEIGHT + grid.size.height

      super(@width, @height, false, 50)

      self.caption = "Ankh #{@game.title}"

      @font   = ResourceLoader.fonts(self)
      @image  = ResourceLoader.images(self)
      @drawer = Drawer.new(self)

      initial_state
    end

    def needs_cursor?
      true
    end

    def update
      update_cell    unless @char.nil?
      update_current unless @position.nil?

      highlight
    end

    def draw
      @drawer.background
      @drawer.grid(@help_mode)
      @drawer.clues(@current)

      @overlay.draw if @overlay
    end

    def button_down(btn_id)
      instance_exec(&KEY_FUNCS[btn_id]) if KEY_FUNCS.key? btn_id

      char = button_id_to_char(btn_id)
      @char = char.upcase unless char.nil? || !char.between?('a', 'z')
      @char = '' if btn_id == Gosu::KbBackspace
    end

    private

    def initial_state
      @help_mode  = false
      @start_time = Time.now - @game.elapsed
      @complete   = false

      number    = @grid.first_clue(:across)
      pos       = @grid.cell_pos(number, :across)
      @current  = CurrentState.new(pos, number, :across)
    end

    def current_cell
      @grid.cell_at(@current.gpos)
    end

    def current_word
      @grid.word_cells(@current.number, @current.dir)
    end

    def highlight
      current_word.each do |gpoint|
        @grid.cell_at(gpoint).highlight = :word
      end

      current_cell.highlight = :current
    end

    def unhighlight
      current_word.each do |gpoint|
        @grid.cell_at(gpoint).highlight = :none
      end

      current_cell.highlight = :none
    end

    def update_cell
      unhighlight

      if @char.empty?
        empty_cell
      else
        current_cell.user = @char
        check_complete
        @grid.next_word_cell(@current)
      end

      @char = nil
    end

    def check_complete
      case @grid.completed
      when :complete
        @complete = true
        @overlay  = CompleteOverlay.new(self)

      when :wrong then @help_mode = true
      end
    end

    def empty_cell
      cell_empty = current_cell.empty?

      @grid.prev_word_cell(@current) if cell_empty

      current_cell.user = ''
      current_cell.highlight = :none

      @grid.prev_word_cell(@current) unless cell_empty
    end

    def update_current
      unhighlight

      return set_current_from_clue if @position.out_of_range?(@grid)

      set_current_from_cell

      @position = nil
    end

    # Clicked out of the grid, probably on a clue

    def set_current_from_clue
      mouse_pos = Point.new(mouse_x, mouse_y)

      @grid.clues.each do |clue|
        next if clue.region.nil? || !clue.region.contains?(mouse_pos)

        @current = CurrentState.from_clue(clue, grid)
        break
      end

      @position = nil
    end

    # Clicked inside the grid

    def set_current_from_cell
      new_num = @grid.word_num_from_pos(@position, @current.dir)

      # Blank square, most likely
      return if new_num == 0

      # Click on current == swap direction
      if @position == @current.gpos
        @current.swap_direction
        new_num = @grid.word_num_from_pos(@position, @current.dir)
      end

      @current.new_word(new_num, @position)
    end

    def handle_escape
      @game.elapsed = Time.now - @start_time
      GameRepository.save_ankh_file(@game) unless @complete

      close
    end

    # Move to the next or previous clue

    def handle_tab
      unhighlight

      if shift_pressed?
        number = @grid.prev_clue(@current.number, @current.dir)
      else
        number = @grid.next_clue(@current.number, @current.dir)
      end

      @current.new_word(number, @grid.cell_pos(number, @current.dir))
    end

    def shift_pressed?
      button_down?(Gosu::KbLeftShift) || button_down?(Gosu::KbRightShift)
    end
  end
end

filename = ARGV[0] || 'Puzzles/2014-4-22-LosAngelesTimes.puz'

Crossword::Puzzle.new(filename).show
