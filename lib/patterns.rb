module GameOfLife
  module StaticPatterns

    # - - - -
    # - # # -
    # - # # -
    # - - - -
    module Block
      def self.coordinates
        [
          [1, 1], [1, 2],
          [2, 1], [2, 2]
        ]
      end
    end

    # - - - - - -
    # - - # # - -
    # - # - - # -
    # - - # # - -
    # - - - - - -
    module Beehive
      def self.coordinates
        [
          [3, 1], [4, 1],
          [2, 2], [5, 2],
          [3, 3], [4, 3]
        ]
      end
    end

    # - - - - -
    # - # # - -
    # - # - # -
    # - - # - -
    # - - - - -
    module Boat
      def self.coordinates
        [
          [1, 3],
          [2, 2], [2, 4],
          [3, 2], [3, 3]
        ]
      end
    end
  end

  module RepeatingPatterns

    module Blinker
      def self.cycle
        [self.step_one, self.step_two]
      end

      # - - - - -
      # - - - - -
      # - # # # -
      # - - - - -
      # - - - - -
      def self.step_one
        [
          [2, 3], [3, 3], [4, 3]
        ]
      end

      # - - - - -
      # - - # - -
      # - - # - -
      # - - # - -
      # - - - - -
      def self.step_two
        [
          [3, 2],
          [3, 3],
          [3, 4]
        ]
      end
    end
  end
end
