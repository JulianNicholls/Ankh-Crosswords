# Bufferer for a .puz file, which allows for unpacking values.
class PuzzleBuffer
  SIZES = { 'S' => 2, 'Q' => 8, 'C' => 1 }

  attr_accessor :pos
  alias_method :seek, :pos=

  def initialize(data = nil)
    self.data = data
  end

  def data=(data)
    @data   = data
    @length = data.size
    @pos    = 0
  end

  def checksum(start, length, cksum)
    seek(start)

    length.times do
      bitset = (cksum & 0x0001) != 0

      cksum >>= 1
      cksum |= 0x8000 if bitset
      cksum += unpack('C', 1)
    end

    cksum
  end

  def seek_by(off)
    @pos += off
  end

  def seek_to(text, offset = 0)
    @pos = @data.index(text) + offset
  end

  def unpack_zstring
    str = @data[@pos..-1].unpack('Z' + remaining.to_s)[0]
    @pos += str.size + 1
    str
  end

  def unpack(spec, size = nil)
    unpack_multiple(spec, size)[0]
  end

  def unpack_multiple(spec, size)
    start = @pos
    @pos += (size || SIZES[spec[1]])
    @data[start..@pos].unpack(spec)
  end

  private

  def remaining
    @length - @pos
  end
end
