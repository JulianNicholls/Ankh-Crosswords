#! /usr/bin/env ruby

require 'gosu_enhanced'
require 'pp'
require 'pry'

require './constants'
require './resources'
require './puzloader'
require './crosswordgrid'

module Crossword
  # Crossword!
  class Game < Gosu::Window
    include Constants

    KEY_FUNCS = {
      Gosu::KbEscape  =>  -> { close },
      Gosu::KbTab     =>  -> { highlight( :next ) },
      Gosu::KbSpace   =>  -> { highlight( :swap ) }
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

      @highlighted, @word_cells = [], []
      highlight( :first, :down )
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

    def highlight( number, direction = nil )
      direction ||= @highlighted[1]
      @word_cells.each { |row, col| @grid.cell_at( row, col ).highlighted = false }

      number = @grid.first_clue( direction )    if number == :first
      number = @grid.next_clue( @highlighted[0], direction ) if number == :next

      @word_cells = @grid.word_cells( number, direction )

      @word_cells.each { |row, col| @grid.cell_at( row, col ).highlighted = true }

      @highlighted = [number, direction]
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
      font = @font[:clue]

      list.each do |clue|
        size  = font.measure( clue.text )
        tlc   = pos

        font.draw( clue.number, pos.x, pos.y, 1, 1, 1, WHITE )

        if size.width > CLUE_COLUMN_WIDTH
          draw_wrapped( pos, clue.text, (size.width / CLUE_COLUMN_WIDTH).ceil )
        else
          draw_simple( pos, clue.text )
        end

        clue.region = Region.new( tlc, Size.new( CLUE_COLUMN_WIDTH, pos.y - tlc.y ) )
      end
    end

    def draw_wrapped( pos, text, parts )
      wrap( text, parts ).each do |part|
        draw_simple( pos, part )
      end
    end

    def draw_simple( pos, text )
      font = @font[:clue]

      font.draw( text, pos.x + 18, pos.y, 1, 1, 1, WHITE )
      pos.move_by!( 0, font.height )
    end

    def wrap( text, pieces = 2 )
      return [text] if pieces == 1

      pos    = text.size / pieces
      nspace = text.index( ' ', pos )
      pspace = text.rindex( ' ', pos )

      space = (nspace - pos).abs > (pspace - pos).abs ? pspace : nspace

      [text[0...space]] + wrap( text[space + 1..-1], pieces - 1 )
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

cgrid = CrosswordGrid.new( puz.rows, puz.clues )

Crossword::Game.new( cgrid, puz.title ).show
