require 'gridpoint'
require 'cluelist'
require 'traverser'
require 'cell'

module Crossword
  # Represent a whole crossword grid
  class Grid
    include Constants
    extend Forwardable

    def_delegators :@cluelist, :clues, :clues_of, :across_clues, :down_clues
    def_delegators :@cluelist, :cell_pos
    def_delegators :@cluelist, :first_clue, :next_clue, :prev_clue

    def_delegators :@traverser, :cell_down, :cell_up, :cell_right, :cell_left
    def_delegators :@traverser, :next_word_cell, :prev_word_cell

    attr_reader :width, :height, :size

    def self.from_ankh_file(file)
      width, height = file.gets.chomp.split(',').map(&:to_i)

      this = new
      this.set_dimensions(width, height)

      (width * height).times { this.add_cell(Cell.from_text file.gets.chomp) }

      until (line = file.gets).nil?
        this.add_clue(Clue.from_text line.chomp)
      end

      this
    end

    # raw rows come in as an array of strings with one character per cell,
    # '.' for blank

    def initialize(raw_rows = nil, clues = nil)
      @cluelist       = ClueList.new
      @traverser      = Traverser.new(self)
      @grid           = []

      return unless raw_rows

      set_dimensions(raw_rows[0].size, raw_rows.size)
      build_grid(raw_rows)
      add_numbers_and_clues(clues.to_enum)
    end

    def set_dimensions(width, height)
      @width  = width
      @height = height
      @size   = Size.new(width * CELL_SIZE.width, height * CELL_SIZE.height)
    end

    def add_cell(cell)
      @grid << cell
    end

    def add_clue(clue)
      @cluelist.add(clue, self)
    end

    def cell_at(pos)
      @grid[pos.row * @width + pos.col]
    end

    def each
      height.times do |row|
        width.times do |col|
          pos = GridPoint.new(row, col)
          yield cell_at(pos)
        end
      end
    end

    def each_with_position
      height.times do |row|
        width.times do |col|
          pos = GridPoint.new(row, col)
          yield cell_at(pos), pos
        end
      end
    end

    def word_cells(number, direction)
      gpoint = @cluelist.cell_pos(number, direction)
      word   = [gpoint]

      loop do
        gpoint = @traverser.next_cell(gpoint, direction)
        break if gpoint.nil?
        word << gpoint
      end

      word
    end

    def word_num_from_pos(pos, direction)
      return 0 if cell_at(pos).blank?

      @cluelist.clues_of(direction).each do |clue|
        cells = word_cells(clue.number, direction)
        return clue.number if cells.include? pos
      end

      fail "No word from #{pos}"
    end

    def completed
      each do |cell|
        next if cell.blank?

        return false  if cell.empty?
        return :wrong if cell.error
      end

      :complete
    end

    private

    def build_grid(raw_rows)
      raw_rows.each { |r| r.each_char { |c| add_cell Cell.new(c) } }
    end

    def add_numbers_and_clues(clues)
      number = 1

      each_with_position do |cell, gpoint|
        next if cell.blank?

        nan = needs_across_number?(gpoint)
        ndn = needs_down_number?(gpoint)

        add_clue(Clue.new(:across, number, clues.next, gpoint)) if nan
        add_clue(Clue.new(:down,   number, clues.next, gpoint)) if ndn

        cell.number = (number += 1) - 1 if nan || ndn
      end
    end

    def needs_across_number?(gpoint)
      (gpoint.col == 0 || cell_at(gpoint.offset(0, -1)).blank?) &&
        gpoint.col < @width - 1 && !cell_at(gpoint.offset(0, 1)).blank?
    end

    def needs_down_number?(gpoint)
      (gpoint.row == 0 || cell_at(gpoint.offset(-1, 0)).blank?) &&
        gpoint.row < @height - 1 && !cell_at(gpoint.offset(1, 0)).blank?
    end
  end
end
