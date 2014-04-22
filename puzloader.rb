require 'pp'
require 'forwardable'

# header_format = '''< H 11s xH Q 4s 2sH 12s BBH H H'''
#
# header_cksum_format = '<BBH H H '
# maskstring = 'ICHEATED'
# ACROSSDOWN =
# BLACKSQUARE = '.'
#
# extension_header_format = '< 4s  H H '
#

class PuzzleLoader
  extend Forwardable

  SIGNATURE = 'ACROSS&DOWN'

  def_delegators :@buffer, :unpack, :unpack_multiple, :unpack_zstring, :seek_by

  attr_reader :width, :height, :rows, :num_clues, :clues, :title, :author, :copyright

  def initialize( filename, debug = false )
    @buffer = PuzzleBuffer.new( read filename )

    # Skip past an optional pre-header

    @buffer.seek_to( 'ACROSS&DOWN', -2 )

    if debug
      load_irrelevances
    else
      @buffer.seek_by( 2+12+2+4+4+4+2+2+12 )
    end

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

  def load_irrelevances
    @file_checksum = unpack( '<S' )
    debug 'File Checksum', @file_checksum

    @sig = unpack_zstring
    puts "Signature: #{@sig}"

    @cib_checksum = unpack( '<S' )
    debug 'CIB Checksum', @cib_checksum

    @lowparts  = unpack_multiple( 'C4', 4 )
    @highparts = unpack_multiple( 'C4', 4 )

    pp @lowparts, @highparts

    @version = unpack( 'Z4', 4 )
    puts "Version: #{@version}"

    @reserved1c = unpack( '<S' )
    debug 'Reverved?', @reserved1c

    @scrambled_checksum = unpack( '<S' )
    debug 'Scrambled Checksum', @scrambled_checksum

    @reserved20 = unpack_multiple( 'C12', 12 )
    pp @reserved20
  end

  def load_size
    @width, @height, @num_clues = unpack_multiple( 'C2<S', 4 )
    seek_by( 2 )
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
      data = file.read()
    end

    data
  end

  def debug( name, value )
    printf "%s: %d %04x\n", name, value, value
  end
end

# Bufferer for a .puz file which allows for unpacking values.
class PuzzleBuffer
  SIZES = { 'S' => 2, 'Q' => 8, 'C' => 1 }

  attr_reader :pos, :data

  def initialize( data = nil )
    self.data = data
  end

  def data=( data )
    @data = data
    @length = data.size
    @pos  = 0

    puts "PB - Data: #{data.size} Bytes."
  end

  def seek( pos )
    @pos = pos
  end

  def seek_by( off )
    @pos += off
  end

  def seek_to( text, offset )
    @pos = @data.index( text ) + offset
  end

  def unpack_multiple( spec, size )
    start =  @pos
    @pos  += (size || SIZES[spec[1]])
    @data[start..@pos].unpack( spec )
  end

  def unpack_zstring
    str = @data[@pos..-1].unpack( 'Z' + remaining.to_s )[0]
    @pos += str.size + 1
    str
  end

  def unpack( spec, size = nil )
    unpack_multiple( spec, size )[0]
  end

  private

  def remaining
    @length - @pos
  end
end

def debug( name, value )
  printf "%s: %d %04x\n", name, value, value
end

puz = PuzzleLoader.new( '2014-4-22-LosAngelesTimes.puz' )

debug 'Width ', puz.width
debug 'Height', puz.height
debug 'Clues ', puz.num_clues
debug 'Scrambled', puz.scrambled? ? 1 : 0

    puts %{
Title:  #{puz.title}
Author: #{puz.author}
Copy:   #{puz.copyright}
}

puz.rows.each { |row| puts row }


puz.clues.each { |clue| puts clue }
