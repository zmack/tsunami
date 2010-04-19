require 'forwardable'

class Tsunami
  class Bucket
    extend ::Forwardable

    def_delegator :@values, :each, :each_value
    def_delegator :@values, :each_with_index, :each_value_with_index

    attr_reader :width, :height, :frames

    def initialize(frames, width, height)
      @values = []
      @frames = frames
      @width = width
      @height = height
    end

    def set(frame, value)
      frame_values = values(frame)

      frame_values[:min] = value if value < frame_values[:min]

      frame_values[:max] = value if value > frame_values[:max]
    end

    def frames_per_pixel
      @frames_per_pixel ||= frames / @width
    end

    def index(frame)
      frame / frames_per_pixel
    end

    def values(frame)
      @values[index(frame)] ||= { :max => -1, :min => 1 }
    end
  end
end
