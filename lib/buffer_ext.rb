unless RubyAudio::Buffer.included_modules.include? Enumerable

  module RubyAudio
    class Buffer
      include Enumerable

      def each 
        self.size.times do |i|
          yield self[i]
        end
      end
    end
  end

end
