require 'pp'
require 'forwardable'

require './puzbuffer'

# Loader for a .puz file.
class PuzzleLoader
  extend Forwardable

  SIGNATURE = 'ACROSS&DOWN'

  def_delegators :@buffer, :unpack, :unpack_multiple, :unpack_zstring,
                 :seek_by, :seek_to

  attr_reader :width, :height, :rows, :num_clues, :clues, :title, :author, :copyright

  def initialize( filename, debug = false )
    @buffer = PuzzleBuffer.new( read filename )

    # Skip past an optional pre-header
    seek_to( 'ACROSS&DOWN', -2 )

    debug ? load_check_values : seek_by( 2 + 12 + 2 + 4 + 4 + 4 + 2 + 2 + 12 )

    load_size
    load_answer
    skip_solution
    load_info
    load_clues
  end

  def scrambled?
    @scrambled != 0
  end

  private

  def load_check_values
    @file_checksum  = unpack( '<S' )
    @sig            = unpack_zstring
    @cib_checksum   = unpack( '<S' )
    @lowparts       = unpack_multiple( 'C4', 4 )
    @highparts      = unpack_multiple( 'C4', 4 )
    @version        = unpack( 'Z4', 4 )
    @reserved1c     = unpack( '<S' )
    @scrambled_checksum = unpack( '<S' )
    @reserved20     = unpack_multiple( 'C12', 12 )

    debug 'File Checksum', @file_checksum
    puts "Signature: #{@sig}"
    debug 'CIB Checksum', @cib_checksum
    pp @lowparts, @highparts
    puts "Version: #{@version}"
    debug 'Reverved?', @reserved1c
    debug 'Scrambled Checksum', @scrambled_checksum
    pp @reserved20
  end

  def load_size
    @width, @height, @num_clues = unpack_multiple( 'C2<S', 4 )
    seek_by( 2 )  # Puzzle Type, 1 = Normal, 0x0401 = Diagramless
    @scrambled = unpack( '<S' )
  end

  def load_answer
    @rows = []
    @height.times { @rows << unpack( 'a' + @width.to_s, @width ) }
  end

  def skip_solution
    seek_by( @width * @height )   # Skip possible solution
  end

  def load_info
    @title      = unpack_zstring
    @author     = unpack_zstring
    @copyright  = unpack_zstring
  end

  def load_clues
    @clues = []
    @num_clues.times { @clues << unpack_zstring }
  end

  def read( filename )
    data = ''

    open( filename, 'rb' ) do |file|
      data = file.read
    end

    data
  end

  def debug( name, value )
    printf "%s: %d %04x\n", name, value, value
  end
end
