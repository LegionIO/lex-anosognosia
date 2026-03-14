# frozen_string_literal: true

RSpec.describe Legion::Extensions::Anosognosia do
  it 'has a version number' do
    expect(Legion::Extensions::Anosognosia::VERSION).not_to be_nil
  end

  it 'has a version that is a string' do
    expect(Legion::Extensions::Anosognosia::VERSION).to be_a(String)
  end

  it 'has the correct version' do
    expect(Legion::Extensions::Anosognosia::VERSION).to eq('0.1.0')
  end
end
