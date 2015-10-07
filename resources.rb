require 'gosu_enhanced'

module Crossword
  # Resource Loader
  class ResourceLoader
    def self.fonts(window)
      default = Gosu.default_font_name

      {
        cell:     Gosu::Font.new(window, default, 16),
        number:   Gosu::Font.new(window, default, 8),
        clue:     Gosu::Font.new(window, default, 11),
        header:   Gosu::Font.new(window, default, 19),
        o_title:  Gosu::Font.new(window, default, 24)
      }
    end

    def self.images(window)
      {
        ankh:   Gosu::Image.new(window, 'media/ankh.png', true)
      }
    end
  end
end
