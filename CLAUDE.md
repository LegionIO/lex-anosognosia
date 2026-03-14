# lex-anosognosia

**Level 3 Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Grandparent**: `/Users/miverso2/rubymine/legion/CLAUDE.md`

## Purpose

Cognitive deficit awareness modeling for brain-modeled agentic AI — tracks blind spots, awareness gaps, and calibration. Anosognosia is the clinical term for unawareness of one's own deficits; this extension models the meta-cognitive capacity to detect and acknowledge what the agent doesn't know or can't do.

## Gem Info

- **Gem name**: `lex-anosognosia`
- **Version**: `0.1.0`
- **Module**: `Legion::Extensions::Anosognosia`
- **Ruby**: `>= 3.4`
- **License**: MIT

## File Structure

```
lib/legion/extensions/anosognosia/
  anosognosia.rb             # Main extension module
  version.rb                 # VERSION = '0.1.0'
  client.rb                  # Client wrapper
  helpers/
    constants.rb             # Limits, decay/boost rates, labels, deficit types
    cognitive_deficit.rb     # CognitiveDeficit value object
    anosognosia_engine.rb    # AnosognosiaEngine — manages deficits, awareness score
  runners/
    anosognosia.rb           # Runner module with 8 public methods
spec/
  (spec files)
```

## Key Constants

```ruby
MAX_DEFICITS    = 200
AWARENESS_DECAY = 0.02   # per-tick awareness reduction
AWARENESS_BOOST = 0.1    # boost when a blind spot is revealed
AWARENESS_LABELS = {
  (0.8..1.0)  => :calibrated,
  (0.6...0.8) => :mostly_aware,
  (0.4...0.6) => :partially_blind,
  (0.2...0.4) => :largely_blind,
  (0.0...0.2) => :anosognosic
}
DEFICIT_TYPES = %i[knowledge reasoning memory perception attention judgment]
```

## Runners

### `Runners::Anosognosia`

All methods delegate to a private `@engine` (`Helpers::AnosognosiaEngine` instance).

- `register_deficit(domain:, deficit_type:, severity:, acknowledged: false)` — register a known or unknown deficit
- `acknowledge_deficit(deficit_id:)` — explicitly acknowledge a deficit; triggers awareness recalculation
- `reveal_blind_spot(deficit_id:)` — reveals a previously unacknowledged deficit; boosts awareness score
- `awareness_score` — current awareness score (0–1), gap, and label
- `awareness_gap` — returns `1.0 - awareness_score` (the blind zone)
- `blind_spots` — all unacknowledged deficits
- `calibration_report` — comprehensive report: totals, breakdown by deficit type, blind spots list
- `decay_awareness(amount: nil)` — reduce awareness score (models forgetting about deficits over time)
- `anosognosia_status` — quick status hash (total, score, blind spot count)

## Helpers

### `Helpers::AnosognosiaEngine`
Core engine. `@awareness_score` starts at 1.0. `recalculate_awareness` = `acknowledged / total` (ratio of known deficits to all deficits). `reveal_blind_spot` triggers a discrete `AWARENESS_BOOST` in addition to recalculation. Prunes oldest unacknowledged deficit when at capacity.

### `Helpers::CognitiveDeficit`
Value object. Validates `deficit_type` against `DEFICIT_TYPES`. `acknowledge!` is idempotent (returns false if already acknowledged). `severity_label` maps 0–1 severity to `:minimal`, `:low`, `:moderate`, `:high`, `:severe`.

## Integration Points

No actor defined. Integrates with lex-tick's meta-awareness phases. The `awareness_score` can gate how confidently the agent reports its own capabilities. `blind_spots` can be input to lex-dream's contradiction_resolution phase to surface unacknowledged knowledge gaps. `calibration_report` is useful for governance and oversight via lex-governance.

## Development Notes

- `awareness_score` is a ratio: fully acknowledged = 1.0, zero acknowledged = 0.0
- `decay_awareness` is a flat reduction (not recalculation), modeling gradual forgetting — call when new information suggests previously known deficits may have re-emerged
- Severity is stored as a float (0.0–1.0) and displayed via label; the awareness calculation does not weight by severity — all deficits count equally
- `deficit_type` validation raises `ArgumentError` on invalid types, unlike most other extensions which return error hashes
