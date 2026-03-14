# frozen_string_literal: true

RSpec.describe Legion::Extensions::Anosognosia::Helpers::Constants do
  describe 'MAX_DEFICITS' do
    it 'is 200' do
      expect(described_class::MAX_DEFICITS).to eq(200)
    end
  end

  describe 'AWARENESS_DECAY' do
    it 'is 0.02' do
      expect(described_class::AWARENESS_DECAY).to eq(0.02)
    end
  end

  describe 'AWARENESS_BOOST' do
    it 'is 0.1' do
      expect(described_class::AWARENESS_BOOST).to eq(0.1)
    end
  end

  describe 'AWARENESS_LABELS' do
    it 'includes all expected labels' do
      labels = described_class::AWARENESS_LABELS.values
      expect(labels).to include(:calibrated, :mostly_aware, :partially_blind, :largely_blind, :anosognosic)
    end

    it 'has 5 labels' do
      expect(described_class::AWARENESS_LABELS.size).to eq(5)
    end

    it 'maps 1.0 to calibrated' do
      label = described_class::AWARENESS_LABELS.find { |range, _| range.include?(1.0) }&.last
      expect(label).to eq(:calibrated)
    end

    it 'maps 0.0 to anosognosic' do
      label = described_class::AWARENESS_LABELS.find { |range, _| range.include?(0.0) }&.last
      expect(label).to eq(:anosognosic)
    end
  end

  describe 'DEFICIT_TYPES' do
    it 'includes all six deficit types' do
      expect(described_class::DEFICIT_TYPES).to include(
        :knowledge, :reasoning, :memory, :perception, :attention, :judgment
      )
    end

    it 'has exactly six types' do
      expect(described_class::DEFICIT_TYPES.size).to eq(6)
    end

    it 'is frozen' do
      expect(described_class::DEFICIT_TYPES).to be_frozen
    end
  end
end
