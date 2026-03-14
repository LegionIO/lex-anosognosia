# frozen_string_literal: true

RSpec.describe Legion::Extensions::Anosognosia::Helpers::CognitiveDeficit do
  subject(:deficit) do
    described_class.new(domain: :language, deficit_type: :knowledge, severity: 0.6)
  end

  describe '#initialize' do
    it 'assigns a uuid id' do
      expect(deficit.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'assigns domain' do
      expect(deficit.domain).to eq(:language)
    end

    it 'assigns deficit_type' do
      expect(deficit.deficit_type).to eq(:knowledge)
    end

    it 'assigns severity' do
      expect(deficit.severity).to eq(0.6)
    end

    it 'defaults acknowledged to false' do
      expect(deficit.acknowledged).to be false
    end

    it 'assigns discovered_at' do
      expect(deficit.discovered_at).to be_a(Time)
    end

    it 'leaves acknowledged_at nil' do
      expect(deficit.acknowledged_at).to be_nil
    end

    it 'clamps severity above 1.0 to 1.0' do
      d = described_class.new(domain: :test, deficit_type: :reasoning, severity: 1.5)
      expect(d.severity).to eq(1.0)
    end

    it 'clamps severity below 0.0 to 0.0' do
      d = described_class.new(domain: :test, deficit_type: :reasoning, severity: -0.5)
      expect(d.severity).to eq(0.0)
    end

    it 'raises ArgumentError for invalid deficit_type' do
      expect do
        described_class.new(domain: :test, deficit_type: :invalid_type, severity: 0.5)
      end.to raise_error(ArgumentError, /Invalid deficit_type/)
    end

    it 'accepts acknowledged: true' do
      d = described_class.new(domain: :test, deficit_type: :memory, severity: 0.3, acknowledged: true)
      expect(d.acknowledged).to be true
    end
  end

  describe '#acknowledge!' do
    it 'sets acknowledged to true' do
      deficit.acknowledge!
      expect(deficit.acknowledged).to be true
    end

    it 'sets acknowledged_at timestamp' do
      deficit.acknowledge!
      expect(deficit.acknowledged_at).to be_a(Time)
    end

    it 'returns true when newly acknowledged' do
      expect(deficit.acknowledge!).to be true
    end

    it 'returns false when already acknowledged' do
      deficit.acknowledge!
      expect(deficit.acknowledge!).to be false
    end

    it 'does not update acknowledged_at on second call' do
      deficit.acknowledge!
      first_time = deficit.acknowledged_at
      sleep(0.001)
      deficit.acknowledge!
      expect(deficit.acknowledged_at).to eq(first_time)
    end
  end

  describe '#severity_label' do
    it 'returns :severe for severity >= 0.8' do
      d = described_class.new(domain: :t, deficit_type: :attention, severity: 0.9)
      expect(d.severity_label).to eq(:severe)
    end

    it 'returns :high for severity in 0.6..0.8' do
      d = described_class.new(domain: :t, deficit_type: :attention, severity: 0.7)
      expect(d.severity_label).to eq(:high)
    end

    it 'returns :moderate for severity in 0.4..0.6' do
      d = described_class.new(domain: :t, deficit_type: :attention, severity: 0.5)
      expect(d.severity_label).to eq(:moderate)
    end

    it 'returns :low for severity in 0.2..0.4' do
      d = described_class.new(domain: :t, deficit_type: :attention, severity: 0.3)
      expect(d.severity_label).to eq(:low)
    end

    it 'returns :minimal for severity < 0.2' do
      d = described_class.new(domain: :t, deficit_type: :attention, severity: 0.1)
      expect(d.severity_label).to eq(:minimal)
    end
  end

  describe '#to_h' do
    let(:h) { deficit.to_h }

    it 'includes id' do
      expect(h[:id]).to eq(deficit.id)
    end

    it 'includes domain' do
      expect(h[:domain]).to eq(:language)
    end

    it 'includes deficit_type' do
      expect(h[:deficit_type]).to eq(:knowledge)
    end

    it 'includes severity rounded to 10 places' do
      expect(h[:severity]).to eq(0.6.round(10))
    end

    it 'includes severity_label' do
      expect(h[:severity_label]).to eq(:high)
    end

    it 'includes acknowledged' do
      expect(h[:acknowledged]).to be false
    end

    it 'includes discovered_at' do
      expect(h[:discovered_at]).to be_a(Time)
    end

    it 'includes acknowledged_at' do
      expect(h).to have_key(:acknowledged_at)
    end
  end
end
