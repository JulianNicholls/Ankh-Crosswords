module Crossword
  # Represent a whole crossword grid
  class Grid
    class Storer
      def self.save( filename, title, grid )
        open( filename, 'w' ) do |file|
          file.puts title
          file.puts "#{grid.width},#{grid.height}"
          grid.each_with_position { |cell, _| file.puts cell.to_text }
          grid.clues.each { |clue| file.puts clue.to_text }
        end
      end
    end
  end
end