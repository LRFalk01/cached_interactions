# frozen_string_literal: true

RSpec.describe CachedInteractions do
  it "has a version number" do
    expect(CachedInteractions::VERSION).not_to be nil
  end

  it "does something useful" do
    puts 'run 1'
    SpecInteraction::CachedInteraction.run(id: 1, testing: 1)

    puts 'run 2'
    SpecInteraction::CachedInteraction.run(id: 1, testing: 1)
  end
end
