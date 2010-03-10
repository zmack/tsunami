#this class was inspired by rjp's awesome http://github.com/rjp/cdcover
require 'rubygems'
require 'RMagick'
require 'audio/sndfile'

class Tsunami

  def initialize audio_file
    @audio_file = Audio::Soundfile.new audio_file
  end

  def create_waveform(image_file, options)
    @width = options[:width] || 100
    @height = options[:height] || 50

    buckets = fill_buckets

    gc = build_graph buckets

    canvas = Magick::Image.new(@width, @height) { self.background_color = 'transparent' }

    gc.draw(canvas)

    canvas.write(image_file)
  end

  def fill_buckets
    frames = @audio_file.read_float(@audio_file.frames).channel(0)
    buckets = []
    frame_index = 0
    frames_per_pixel = frames.length / @width

    frames.each do |frame|
      index = frame_index / frames_per_pixel
      buckets[index] ||= { :max => -1, :min => 1 }

      buckets[index][:min] = frame if frame < buckets[index][:min]

      buckets[index][:max] = frame if frame > buckets[index][:max]

      frame_index += 1
    end

    return buckets
  end

  def build_graph buckets
    gc = Magick::Draw.new
    gc.stroke('red')
    gc.stroke_width(1)

    mid = @height/2

    buckets.each_with_index do |bucket, i|
      low = bucket[:min]
      high = bucket[:max]

      low_point = mid * ( 1 - low )
      high_point = mid * ( 1 - high )

      gc.line(i, low_point.to_i, i, high_point.to_i)
    end

    return gc
  end
end
