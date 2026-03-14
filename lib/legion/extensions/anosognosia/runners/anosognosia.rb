# frozen_string_literal: true

module Legion
  module Extensions
    module Anosognosia
      module Runners
        module Anosognosia
          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex)

          def register_deficit(domain:, deficit_type:, severity:, acknowledged: false, **)
            deficit = engine.register_deficit(
              domain:       domain,
              deficit_type: deficit_type,
              severity:     severity,
              acknowledged: acknowledged
            )
            {
              registered:      true,
              deficit_id:      deficit.id,
              domain:          domain,
              deficit_type:    deficit_type,
              severity:        deficit.severity,
              severity_label:  deficit.severity_label,
              acknowledged:    deficit.acknowledged,
              awareness_score: engine.awareness_score.round(10)
            }
          end

          def acknowledge_deficit(deficit_id:, **)
            Legion::Logging.debug "[anosognosia] acknowledge_deficit: id=#{deficit_id}"
            engine.acknowledge_deficit(deficit_id: deficit_id)
          end

          def reveal_blind_spot(deficit_id:, **)
            Legion::Logging.info "[anosognosia] reveal_blind_spot: id=#{deficit_id}"
            engine.reveal_blind_spot(deficit_id: deficit_id)
          end

          def awareness_score(**)
            score = engine.awareness_score
            Legion::Logging.debug "[anosognosia] awareness_score: score=#{score.round(2)}"
            {
              awareness_score: score.round(10),
              awareness_gap:   engine.awareness_gap,
              awareness_label: awareness_label_for(score)
            }
          end

          def awareness_gap(**)
            gap = engine.awareness_gap
            Legion::Logging.debug "[anosognosia] awareness_gap: gap=#{gap.round(2)}"
            { awareness_gap: gap, awareness_score: engine.awareness_score.round(10) }
          end

          def blind_spots(**)
            spots = engine.blind_spots
            Legion::Logging.debug "[anosognosia] blind_spots: count=#{spots.size}"
            { blind_spots: spots.map(&:to_h), count: spots.size }
          end

          def calibration_report(**)
            Legion::Logging.info '[anosognosia] calibration_report requested'
            engine.calibration_report
          end

          def decay_awareness(amount: nil, **)
            amt   = amount || Helpers::Constants::AWARENESS_DECAY
            score = engine.decay_awareness(amount: amt)
            { awareness_score: score.round(10), awareness_gap: engine.awareness_gap, decayed_by: amt }
          end

          def anosognosia_status(**)
            { total_deficits: engine.deficits.size, awareness_score: engine.awareness_score.round(10),
              blind_spot_count: engine.blind_spots.size }
          end

          private

          def engine
            @engine ||= Helpers::AnosognosiaEngine.new
          end

          def awareness_label_for(score)
            Helpers::Constants::AWARENESS_LABELS.each do |range, label|
              return label if range.include?(score)
            end
            :anosognosic
          end
        end
      end
    end
  end
end
