require 'RMagick'
require 'tsunami_ext'

class Tsunami
  attr_accessor :width, :height

  def initialize audio_file
    raise Errno::ENOENT.new(audio_file) unless File.exist? audio_file

    @file_name = audio_file
  end

  def create_waveform(image_file, width, height)
    self.width = width
    self.height = height

    values = TsunamiC.get_stats(@file_name, width)

    canvas = draw_waveform(values)

    canvas.write(image_file)
  end

  def draw_waveform(values)
    gc = build_graph(values)

    canvas = Magick::Image.new(width, height) { self.background_color = 'transparent' }

    gc.draw(canvas)

    canvas
  end

  def build_graph(values)
    gc = Magick::Draw.new
    gc.stroke('red')
    gc.stroke_width(1)

    mid = height / 2

    values.each_with_index do |values, i|
      low = values[:min]
      high = values[:max]

      low_point = mid * ( 1 - low )
      high_point = mid * ( 1 - high )

      gc.line(i, low_point.to_i, i, high_point.to_i)
    end

    return gc
  end

end
