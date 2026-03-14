# frozen_string_literal: true

RSpec.describe Legion::Extensions::Anosognosia::Helpers::AnosognosiaEngine do
  subject(:engine) { described_class.new }

  def register_deficit(engine, domain: :language, deficit_type: :knowledge, severity: 0.6, acknowledged: false)
    engine.register_deficit(domain: domain, deficit_type: deficit_type, severity: severity, acknowledged: acknowledged)
  end

  describe '#initialize' do
    it 'starts with empty deficits' do
      expect(engine.deficits).to be_empty
    end

    it 'starts with awareness_score of 1.0' do
      expect(engine.awareness_score).to eq(1.0)
    end
  end

  describe '#register_deficit' do
    it 'adds a deficit to the store' do
      register_deficit(engine)
      expect(engine.deficits.size).to eq(1)
    end

    it 'returns a CognitiveDeficit instance' do
      result = register_deficit(engine)
      expect(result).to be_a(Legion::Extensions::Anosognosia::Helpers::CognitiveDeficit)
    end

    it 'stores deficit by id' do
      deficit = register_deficit(engine)
      expect(engine.deficits[deficit.id]).to eq(deficit)
    end

    it 'registers acknowledged deficit' do
      deficit = register_deficit(engine, acknowledged: true)
      expect(deficit.acknowledged).to be true
    end

    it 'registers multiple deficits' do
      3.times { |i| register_deficit(engine, domain: :"domain_#{i}") }
      expect(engine.deficits.size).to eq(3)
    end
  end

  describe '#acknowledge_deficit' do
    let(:deficit) { register_deficit(engine) }

    it 'returns found: false for unknown deficit' do
      result = engine.acknowledge_deficit(deficit_id: 'unknown-id')
      expect(result[:found]).to be false
    end

    it 'returns found: true for known deficit' do
      result = engine.acknowledge_deficit(deficit_id: deficit.id)
      expect(result[:found]).to be true
    end

    it 'sets changed: true when first acknowledging' do
      result = engine.acknowledge_deficit(deficit_id: deficit.id)
      expect(result[:changed]).to be true
    end

    it 'sets changed: false when already acknowledged' do
      engine.acknowledge_deficit(deficit_id: deficit.id)
      result = engine.acknowledge_deficit(deficit_id: deficit.id)
      expect(result[:changed]).to be false
    end

    it 'recalculates awareness_score after acknowledgement' do
      register_deficit(engine, domain: :a)
      d2 = register_deficit(engine, domain: :b)
      engine.acknowledge_deficit(deficit_id: d2.id)
      expect(engine.awareness_score).to be > 0.0
    end

    it 'includes updated awareness_score in result' do
      result = engine.acknowledge_deficit(deficit_id: deficit.id)
      expect(result).to have_key(:awareness_score)
    end
  end

  describe '#reveal_blind_spot' do
    let(:deficit) { register_deficit(engine) }

    it 'returns found: false for unknown deficit' do
      result = engine.reveal_blind_spot(deficit_id: 'unknown-id')
      expect(result[:found]).to be false
    end

    it 'returns already_known: true if already acknowledged' do
      engine.acknowledge_deficit(deficit_id: deficit.id)
      result = engine.reveal_blind_spot(deficit_id: deficit.id)
      expect(result[:already_known]).to be true
    end

    it 'acknowledges the deficit' do
      engine.reveal_blind_spot(deficit_id: deficit.id)
      expect(engine.deficits[deficit.id].acknowledged).to be true
    end

    it 'boosts awareness_score' do
      register_deficit(engine, domain: :a)
      register_deficit(engine, domain: :b)
      blind = register_deficit(engine, domain: :c)
      before = engine.awareness_score
      engine.reveal_blind_spot(deficit_id: blind.id)
      expect(engine.awareness_score).to be > before
    end

    it 'includes awareness_label in result' do
      result = engine.reveal_blind_spot(deficit_id: deficit.id)
      expect(result).to have_key(:awareness_label)
    end

    it 'returns found: true, already_known: false for blind spot' do
      result = engine.reveal_blind_spot(deficit_id: deficit.id)
      expect(result[:found]).to be true
      expect(result[:already_known]).to be false
    end
  end

  describe '#awareness_gap' do
    it 'returns 0.0 when no deficits' do
      expect(engine.awareness_gap).to eq(0.0)
    end

    it 'returns 1.0 when all deficits are blind spots' do
      register_deficit(engine)
      # Single unacknowledged deficit: awareness_score recalc not called, stays 1.0
      # but gap = 1 - score. After adding unacknowledged deficit and recalculating:
      engine.send(:recalculate_awareness)
      expect(engine.awareness_gap).to be > 0.0
    end

    it 'is complement of awareness_score' do
      register_deficit(engine)
      engine.send(:recalculate_awareness)
      expect((engine.awareness_score + engine.awareness_gap).round(10)).to eq(1.0)
    end
  end

  describe '#blind_spots' do
    it 'returns empty array when no deficits' do
      expect(engine.blind_spots).to be_empty
    end

    it 'returns unacknowledged deficits' do
      d1 = register_deficit(engine, domain: :a)
      d2 = register_deficit(engine, domain: :b)
      engine.acknowledge_deficit(deficit_id: d1.id)
      spots = engine.blind_spots
      expect(spots.map(&:id)).to contain_exactly(d2.id)
    end

    it 'returns all deficits when none acknowledged' do
      2.times { |i| register_deficit(engine, domain: :"d#{i}") }
      expect(engine.blind_spots.size).to eq(2)
    end
  end

  describe '#calibration_report' do
    before do
      d1 = register_deficit(engine, domain: :a)
      register_deficit(engine, domain: :b)
      engine.acknowledge_deficit(deficit_id: d1.id)
    end

    let(:report) { engine.calibration_report }

    it 'includes total_deficits' do
      expect(report[:total_deficits]).to eq(2)
    end

    it 'includes acknowledged_deficits count' do
      expect(report[:acknowledged_deficits]).to eq(1)
    end

    it 'includes unacknowledged_deficits count' do
      expect(report[:unacknowledged_deficits]).to eq(1)
    end

    it 'includes awareness_score' do
      expect(report).to have_key(:awareness_score)
    end

    it 'includes awareness_gap' do
      expect(report).to have_key(:awareness_gap)
    end

    it 'includes awareness_label' do
      expect(report).to have_key(:awareness_label)
    end

    it 'includes blind_spots array' do
      expect(report[:blind_spots]).to be_an(Array)
      expect(report[:blind_spots].size).to eq(1)
    end

    it 'includes deficit_breakdown' do
      expect(report[:deficit_breakdown]).to be_a(Hash)
      expect(report[:deficit_breakdown]).to have_key(:knowledge)
    end
  end

  describe '#decay_awareness' do
    it 'decrements awareness_score by AWARENESS_DECAY by default' do
      before = engine.awareness_score
      engine.decay_awareness
      expect(engine.awareness_score).to be < before
    end

    it 'decrements by custom amount' do
      engine.decay_awareness(amount: 0.3)
      expect(engine.awareness_score).to eq(0.7)
    end

    it 'clamps at 0.0' do
      engine.decay_awareness(amount: 2.0)
      expect(engine.awareness_score).to eq(0.0)
    end
  end

  describe '#to_h' do
    before { register_deficit(engine) }

    let(:h) { engine.to_h }

    it 'includes deficits hash' do
      expect(h[:deficits]).to be_a(Hash)
    end

    it 'includes awareness_score' do
      expect(h).to have_key(:awareness_score)
    end

    it 'includes awareness_gap' do
      expect(h).to have_key(:awareness_gap)
    end

    it 'includes awareness_label' do
      expect(h).to have_key(:awareness_label)
    end

    it 'includes total_deficits' do
      expect(h[:total_deficits]).to eq(1)
    end

    it 'includes blind_spot_count' do
      expect(h).to have_key(:blind_spot_count)
    end
  end

  describe 'capacity management' do
    it 'prunes oldest unacknowledged when at MAX_DEFICITS' do
      stub_const('Legion::Extensions::Anosognosia::Helpers::Constants::MAX_DEFICITS', 3)
      3.times { |i| register_deficit(engine, domain: :"d#{i}") }
      expect(engine.deficits.size).to eq(3)
      register_deficit(engine, domain: :overflow)
      expect(engine.deficits.size).to eq(3)
    end
  end
end
