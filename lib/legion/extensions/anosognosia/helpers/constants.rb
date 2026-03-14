# frozen_string_literal: true

module Legion
  module Extensions
    module Anosognosia
      module Helpers
        module Constants
          MAX_DEFICITS     = 200
          AWARENESS_DECAY  = 0.02
          AWARENESS_BOOST  = 0.1

          AWARENESS_LABELS = {
            (0.8..1.0)  => :calibrated,
            (0.6...0.8) => :mostly_aware,
            (0.4...0.6) => :partially_blind,
            (0.2...0.4) => :largely_blind,
            (0.0...0.2) => :anosognosic
          }.freeze

          DEFICIT_TYPES = %i[knowledge reasoning memory perception attention judgment].freeze
        end
      end
    end
  end
end
