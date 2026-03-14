# lex-anosognosia

Cognitive deficit awareness modeling for brain-modeled agentic AI — tracks blind spots, awareness gaps, and calibration.

## What It Does

Models meta-cognitive awareness of the agent's own limitations. Anosognosia is the clinical condition of being unaware of one's own deficits. This extension tracks registered deficits (things the agent doesn't know or can't do), measures how many are acknowledged versus hidden as blind spots, and computes an overall awareness score. The score degrades over time and improves when blind spots are revealed.

## Core Concept: Awareness as Acknowledged/Total Ratio

```ruby
awareness_score = acknowledged_deficits.to_f / total_deficits.to_f
```

A fully calibrated agent has acknowledged all its deficits. An anosognosic agent has many unacknowledged blind spots.

## Usage

```ruby
client = Legion::Extensions::Anosognosia::Client.new

# Register a deficit (acknowledged: false = blind spot)
result = client.register_deficit(
  domain: :temporal_reasoning,
  deficit_type: :reasoning,
  severity: 0.7,
  acknowledged: false
)

# Check current awareness
client.awareness_score
# => { awareness_score: 0.0, awareness_gap: 1.0, awareness_label: :anosognosic }

# Reveal the blind spot (boosts awareness)
client.reveal_blind_spot(deficit_id: result[:deficit_id])
# => { found: true, awareness_score: 0.1, awareness_label: :anosognosic }

# Acknowledge explicitly
client.acknowledge_deficit(deficit_id: id)

# Get full calibration report
client.calibration_report
# => { total_deficits: 5, acknowledged: 3, blind_spots: [...] }
```

## Integration

Wire `blind_spots` output into lex-dream's contradiction_resolution phase to surface unacknowledged knowledge gaps. The `awareness_score` can gate how confidently the agent reports capabilities in governance and oversight contexts.

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
