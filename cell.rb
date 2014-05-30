module Crossword
  # Represent a whole crossword grid
  class Grid
    # Represent one cell in the crossword with its solution letter, user entry,
    # possible number, and highlight state.
    class Cell
      attr_reader :letter, :user, :error
      attr_accessor :number, :highlight

      def self.from_text( line )
        l, u, n = line.split ','
        
        me = new( l )
        me.number = n.to_i unless n.empty?
        me.user = u
        
        me
      end
      
      def initialize( letter )
        @letter = letter
        @user   = ''
        @number = 0
        @highlight = :none
        @error  = false
      end

      def blank?
        @letter == '.'
      end

      def user=( ltr )
        @user  = ltr
        @error = user != '' && letter != user
      end
      
      def to_text
        "#{letter},#{user},#{number}"
      end
    end
  end
end
