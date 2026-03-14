# frozen_string_literal: true

require 'legion/extensions/anosognosia/client'

RSpec.describe Legion::Extensions::Anosognosia::Client do
  let(:client) { described_class.new }

  it 'responds to register_deficit' do
    expect(client).to respond_to(:register_deficit)
  end

  it 'responds to acknowledge_deficit' do
    expect(client).to respond_to(:acknowledge_deficit)
  end

  it 'responds to reveal_blind_spot' do
    expect(client).to respond_to(:reveal_blind_spot)
  end

  it 'responds to awareness_score' do
    expect(client).to respond_to(:awareness_score)
  end

  it 'responds to awareness_gap' do
    expect(client).to respond_to(:awareness_gap)
  end

  it 'responds to blind_spots' do
    expect(client).to respond_to(:blind_spots)
  end

  it 'responds to calibration_report' do
    expect(client).to respond_to(:calibration_report)
  end

  it 'responds to decay_awareness' do
    expect(client).to respond_to(:decay_awareness)
  end

  it 'responds to anosognosia_status' do
    expect(client).to respond_to(:anosognosia_status)
  end

  it 'maintains isolated state per instance' do
    client_a = described_class.new
    client_b = described_class.new
    client_a.register_deficit(domain: :a, deficit_type: :knowledge, severity: 0.5)
    expect(client_b.anosognosia_status[:total_deficits]).to eq(0)
  end
end
