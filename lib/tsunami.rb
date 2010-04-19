#this class was inspired by rjp's awesome http://github.com/rjp/cdcover
require 'rubygems'
require 'RMagick'
require 'ruby-audio'
require 'buffer_ext.rb'
require 'tsunami/bucket'

class Tsunami

  def initialize audio_file
    @audio_file = RubyAudio::Sound.new audio_file
  end

  def create_waveform(image_file, options = {})
    dimensions = {
      :width => options[:width] || 100,
      :height => options[:height] || 50
    }

    versions = {
      image_file => dimensions
    }

    create_waveforms(versions)
  end

  def create_waveforms(versions)
    create_buckets versions
    fill_buckets

    @buckets.each do |key, bucket|
      canvas = draw_waveform_from_bucket(bucket)
      canvas.write(key.to_s)
    end
  end

  def draw_waveform_from_bucket(bucket)
    gc = build_graph bucket

    canvas = Magick::Image.new(bucket.width, bucket.height) { self.background_color = 'transparent' }

    gc.draw(canvas)

    canvas
  end

  def create_buckets(versions)
    @buckets = {}
    versions.each_key do |key|
      @buckets[key] = Bucket.new(total_frames, versions[key][:width], versions[key][:height])
    end
  end

  def fill_buckets
    @audio_file.seek(0,0)
    frames = @audio_file.read("float", total_frames)
    frame_index = 0

    frames.each do |channel_frames|
      if @audio_file.info.channels > 1
        frame = channel_frames[0]
      else
        frame = channel_frames
      end

      @buckets.values.each { |b| b.set(frame_index, frame) }

      frame_index += 1
    end
  end

  def build_graph bucket
    gc = Magick::Draw.new
    gc.stroke('red')
    gc.stroke_width(1)

    mid = bucket.height / 2

    bucket.each_value_with_index do |values, i|
      low = values[:min]
      high = values[:max]

      low_point = mid * ( 1 - low )
      high_point = mid * ( 1 - high )

      gc.line(i, low_point.to_i, i, high_point.to_i)
    end

    return gc
  end

  def total_frames
    @total_frames ||= @audio_file.info.frames
  end

end
