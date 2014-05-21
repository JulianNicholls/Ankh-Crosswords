require 'constants'

module Crossword
  # Represent a cell position in the grid
  class GridPoint < Struct.new( :row, :col )
    include Constants

    def self.from_point( pos )
      new(
        ((pos.y - GRID_ORIGIN.y) / CELL_SIZE.height).floor,
        ((pos.x - GRID_ORIGIN.x) / CELL_SIZE.width).floor
      )
    end

    def out_of_range?( height, width )
      row < 0 || col < 0 ||
      row >= height || col >= width
    end

    def offset( dr, dc = nil )
      if dr.respond_to? :row
        GridPoint.new( row + dr.row, col + dr.col )
      else
        GridPoint.new( row + dr, col + dc )
      end
    end

    def to_point
      GRID_ORIGIN.offset( col * CELL_SIZE.width, row * CELL_SIZE.height )
    end
  end
end
