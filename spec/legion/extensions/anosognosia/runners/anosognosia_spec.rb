# frozen_string_literal: true

require 'legion/extensions/anosognosia/client'

RSpec.describe Legion::Extensions::Anosognosia::Runners::Anosognosia do
  let(:client) { Legion::Extensions::Anosognosia::Client.new }

  def register(client, domain: :language, deficit_type: :knowledge, severity: 0.5)
    client.register_deficit(domain: domain, deficit_type: deficit_type, severity: severity)
  end

  describe '#register_deficit' do
    it 'returns registered: true' do
      result = register(client)
      expect(result[:registered]).to be true
    end

    it 'returns a deficit_id' do
      result = register(client)
      expect(result[:deficit_id]).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'includes severity in result' do
      result = register(client, severity: 0.7)
      expect(result[:severity]).to eq(0.7)
    end

    it 'includes severity_label' do
      result = register(client, severity: 0.7)
      expect(result[:severity_label]).to eq(:high)
    end

    it 'includes acknowledged: false by default' do
      result = register(client)
      expect(result[:acknowledged]).to be false
    end

    it 'includes awareness_score' do
      result = register(client)
      expect(result).to have_key(:awareness_score)
    end
  end

  describe '#acknowledge_deficit' do
    let(:deficit_id) { register(client)[:deficit_id] }

    it 'acknowledges an existing deficit' do
      result = client.acknowledge_deficit(deficit_id: deficit_id)
      expect(result[:found]).to be true
      expect(result[:changed]).to be true
    end

    it 'returns found: false for unknown id' do
      result = client.acknowledge_deficit(deficit_id: 'no-such-id')
      expect(result[:found]).to be false
    end

    it 'returns changed: false when already acknowledged' do
      client.acknowledge_deficit(deficit_id: deficit_id)
      result = client.acknowledge_deficit(deficit_id: deficit_id)
      expect(result[:changed]).to be false
    end
  end

  describe '#reveal_blind_spot' do
    let(:deficit_id) { register(client)[:deficit_id] }

    it 'returns found: true and already_known: false for a blind spot' do
      result = client.reveal_blind_spot(deficit_id: deficit_id)
      expect(result[:found]).to be true
      expect(result[:already_known]).to be false
    end

    it 'returns already_known: true if already acknowledged' do
      client.acknowledge_deficit(deficit_id: deficit_id)
      result = client.reveal_blind_spot(deficit_id: deficit_id)
      expect(result[:already_known]).to be true
    end

    it 'returns found: false for unknown id' do
      result = client.reveal_blind_spot(deficit_id: 'no-such-id')
      expect(result[:found]).to be false
    end

    it 'includes awareness_score for newly revealed spot' do
      result = client.reveal_blind_spot(deficit_id: deficit_id)
      expect(result).to have_key(:awareness_score)
    end

    it 'includes awareness_label for newly revealed spot' do
      result = client.reveal_blind_spot(deficit_id: deficit_id)
      expect(result).to have_key(:awareness_label)
    end
  end

  describe '#awareness_score' do
    it 'returns awareness_score hash' do
      result = client.awareness_score
      expect(result).to have_key(:awareness_score)
    end

    it 'includes awareness_gap' do
      result = client.awareness_score
      expect(result).to have_key(:awareness_gap)
    end

    it 'includes awareness_label' do
      result = client.awareness_score
      expect(result).to have_key(:awareness_label)
    end

    it 'starts at 1.0 (fully calibrated) with no deficits' do
      result = client.awareness_score
      expect(result[:awareness_score]).to eq(1.0)
    end
  end

  describe '#awareness_gap' do
    it 'returns awareness_gap hash' do
      result = client.awareness_gap
      expect(result).to have_key(:awareness_gap)
    end

    it 'includes awareness_score' do
      result = client.awareness_gap
      expect(result).to have_key(:awareness_score)
    end
  end

  describe '#blind_spots' do
    it 'returns empty array when no deficits registered' do
      result = client.blind_spots
      expect(result[:blind_spots]).to be_empty
      expect(result[:count]).to eq(0)
    end

    it 'returns unacknowledged deficits' do
      id1 = register(client, domain: :a)[:deficit_id]
      register(client, domain: :b)
      client.acknowledge_deficit(deficit_id: id1)
      result = client.blind_spots
      expect(result[:count]).to eq(1)
    end
  end

  describe '#calibration_report' do
    before do
      id1 = register(client, domain: :a)[:deficit_id]
      register(client, domain: :b)
      client.acknowledge_deficit(deficit_id: id1)
    end

    let(:report) { client.calibration_report }

    it 'returns a calibration report hash' do
      expect(report).to be_a(Hash)
    end

    it 'includes total_deficits' do
      expect(report[:total_deficits]).to eq(2)
    end

    it 'includes acknowledged_deficits' do
      expect(report[:acknowledged_deficits]).to eq(1)
    end

    it 'includes unacknowledged_deficits' do
      expect(report[:unacknowledged_deficits]).to eq(1)
    end

    it 'includes awareness_label' do
      expect(report).to have_key(:awareness_label)
    end

    it 'includes deficit_breakdown with all types' do
      breakdown = report[:deficit_breakdown]
      Legion::Extensions::Anosognosia::Helpers::Constants::DEFICIT_TYPES.each do |type|
        expect(breakdown).to have_key(type)
      end
    end
  end

  describe '#decay_awareness' do
    it 'reduces awareness_score' do
      before = client.awareness_score[:awareness_score]
      client.decay_awareness
      after = client.awareness_score[:awareness_score]
      expect(after).to be < before
    end

    it 'accepts custom amount' do
      result = client.decay_awareness(amount: 0.5)
      expect(result[:decayed_by]).to eq(0.5)
    end

    it 'includes awareness_score in result' do
      result = client.decay_awareness
      expect(result).to have_key(:awareness_score)
    end

    it 'includes awareness_gap in result' do
      result = client.decay_awareness
      expect(result).to have_key(:awareness_gap)
    end
  end

  describe '#anosognosia_status' do
    it 'returns total_deficits' do
      register(client)
      result = client.anosognosia_status
      expect(result[:total_deficits]).to eq(1)
    end

    it 'returns awareness_score' do
      result = client.anosognosia_status
      expect(result).to have_key(:awareness_score)
    end

    it 'returns blind_spot_count' do
      register(client)
      result = client.anosognosia_status
      expect(result[:blind_spot_count]).to eq(1)
    end
  end
end
