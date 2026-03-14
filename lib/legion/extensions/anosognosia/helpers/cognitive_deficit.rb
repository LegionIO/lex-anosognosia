# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module Anosognosia
      module Helpers
        class CognitiveDeficit
          attr_reader :id, :domain, :deficit_type, :severity, :acknowledged,
                      :discovered_at, :acknowledged_at

          def initialize(domain:, deficit_type:, severity:, acknowledged: false)
            validate_deficit_type!(deficit_type)

            @id              = SecureRandom.uuid
            @domain          = domain
            @deficit_type    = deficit_type
            @severity        = severity.clamp(0.0, 1.0)
            @acknowledged    = acknowledged
            @discovered_at   = Time.now.utc
            @acknowledged_at = nil
          end

          def acknowledge!
            return false if @acknowledged

            @acknowledged    = true
            @acknowledged_at = Time.now.utc
            true
          end

          def severity_label
            case @severity
            when (0.8..1.0)  then :severe
            when (0.6...0.8) then :high
            when (0.4...0.6) then :moderate
            when (0.2...0.4) then :low
            else                  :minimal
            end
          end

          def to_h
            {
              id:              @id,
              domain:          @domain,
              deficit_type:    @deficit_type,
              severity:        @severity.round(10),
              severity_label:  severity_label,
              acknowledged:    @acknowledged,
              discovered_at:   @discovered_at,
              acknowledged_at: @acknowledged_at
            }
          end

          private

          def validate_deficit_type!(deficit_type)
            return if Constants::DEFICIT_TYPES.include?(deficit_type)

            raise ArgumentError, "Invalid deficit_type: #{deficit_type.inspect}. Must be one of #{Constants::DEFICIT_TYPES.inspect}"
          end
        end
      end
    end
  end
end
