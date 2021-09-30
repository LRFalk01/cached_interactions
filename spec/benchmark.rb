require 'benchmark'
require 'pry'

require "../lib/cached_interactions"
require_relative './spec_interaction'

n = 1_000_000

Benchmark.bm do |benchmark|
  benchmark.report("cached") do
    (1..n).each do |n|
      SpecInteraction::CachedInteraction.run(id: 1, testing: 1)
    end
  end

  benchmark.report("standard") do
    (1..n).each do |n|
      SpecInteraction::StandardInteraction.run(id: 1, testing: 1)
    end
  end
end
