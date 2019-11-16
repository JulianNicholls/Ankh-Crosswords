require 'gosu_enhanced'

module Crossword
  # Resource Loader
  class ResourceLoader
    def self.fonts
      default = Gosu.default_font_name

      {
        cell:     Gosu::Font.new(16, name: default),
        number:   Gosu::Font.new(8, name: default),
        clue:     Gosu::Font.new(13, name: default),
        header:   Gosu::Font.new(19, name: default),
        o_title:  Gosu::Font.new(24, name: default)
      }
    end

    def self.images
      {
        ankh:   Gosu::Image.new('media/ankh.png')
      }
    end
  end
end
