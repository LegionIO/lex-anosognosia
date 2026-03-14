# frozen_string_literal: true

module Legion
  module Extensions
    module Anosognosia
      module Helpers
        class AnosognosiaEngine
          attr_reader :deficits, :awareness_score

          def initialize
            @deficits = {} # id => CognitiveDeficit
            @awareness_score = 1.0
          end

          def register_deficit(domain:, deficit_type:, severity:, acknowledged: false)
            prune_if_at_capacity

            deficit = CognitiveDeficit.new(
              domain:       domain,
              deficit_type: deficit_type,
              severity:     severity,
              acknowledged: acknowledged
            )
            @deficits[deficit.id] = deficit

            Legion::Logging.info "[anosognosia] register_deficit: id=#{deficit.id} domain=#{domain} " \
                                 "type=#{deficit_type} severity=#{deficit.severity.round(2)} acknowledged=#{acknowledged}"

            deficit
          end

          def acknowledge_deficit(deficit_id:)
            deficit = @deficits[deficit_id]
            return { found: false, deficit_id: deficit_id } unless deficit

            already = deficit.acknowledged
            changed = deficit.acknowledge!

            Legion::Logging.debug "[anosognosia] acknowledge_deficit: id=#{deficit_id} " \
                                  "already_acknowledged=#{already} changed=#{changed}"

            recalculate_awareness
            { found: true, deficit_id: deficit_id, changed: changed, awareness_score: @awareness_score.round(10) }
          end

          def reveal_blind_spot(deficit_id:)
            deficit = @deficits[deficit_id]
            return { found: false, deficit_id: deficit_id } unless deficit
            return { found: true, deficit_id: deficit_id, already_known: true } if deficit.acknowledged

            deficit.acknowledge!
            boost_awareness

            Legion::Logging.info "[anosognosia] blind_spot_revealed: id=#{deficit_id} domain=#{deficit.domain} " \
                                 "type=#{deficit.deficit_type} awareness_score=#{@awareness_score.round(2)}"

            {
              found:           true,
              deficit_id:      deficit_id,
              already_known:   false,
              awareness_score: @awareness_score.round(10),
              awareness_label: awareness_label
            }
          end

          def awareness_gap
            (1.0 - @awareness_score).clamp(0.0, 1.0).round(10)
          end

          def blind_spots
            @deficits.values.reject(&:acknowledged)
          end

          def calibration_report
            total         = @deficits.size
            acknowledged  = @deficits.values.count(&:acknowledged)
            unacknowledged = total - acknowledged

            {
              total_deficits:          total,
              acknowledged_deficits:   acknowledged,
              unacknowledged_deficits: unacknowledged,
              awareness_score:         @awareness_score.round(10),
              awareness_gap:           awareness_gap,
              awareness_label:         awareness_label,
              blind_spots:             blind_spots.map(&:to_h),
              deficit_breakdown:       deficit_type_breakdown
            }
          end

          def decay_awareness(amount: Constants::AWARENESS_DECAY)
            @awareness_score = (@awareness_score - amount).clamp(0.0, 1.0)
            Legion::Logging.debug "[anosognosia] decay_awareness: score=#{@awareness_score.round(2)}"
            @awareness_score
          end

          def to_h
            {
              deficits:         @deficits.transform_values(&:to_h),
              awareness_score:  @awareness_score.round(10),
              awareness_gap:    awareness_gap,
              awareness_label:  awareness_label,
              total_deficits:   @deficits.size,
              blind_spot_count: blind_spots.size
            }
          end

          private

          def boost_awareness(amount: Constants::AWARENESS_BOOST)
            @awareness_score = (@awareness_score + amount).clamp(0.0, 1.0)
          end

          def recalculate_awareness
            return if @deficits.empty?

            total        = @deficits.size.to_f
            acknowledged = @deficits.values.count(&:acknowledged).to_f
            @awareness_score = (acknowledged / total).clamp(0.0, 1.0)
          end

          def awareness_label
            Constants::AWARENESS_LABELS.each do |range, label|
              return label if range.include?(@awareness_score)
            end
            :anosognosic
          end

          def deficit_type_breakdown
            Constants::DEFICIT_TYPES.to_h do |type|
              matching = @deficits.values.select { |d| d.deficit_type == type }
              [type, { count: matching.size, acknowledged: matching.count(&:acknowledged) }]
            end
          end

          def prune_if_at_capacity
            return unless @deficits.size >= Constants::MAX_DEFICITS

            oldest = @deficits.values
                              .reject(&:acknowledged)
                              .min_by(&:discovered_at)
            oldest ||= @deficits.values.min_by(&:discovered_at)
            @deficits.delete(oldest.id) if oldest
          end
        end
      end
    end
  end
end
