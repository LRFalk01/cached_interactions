# frozen_string_literal: true
require 'active_interaction'

require_relative "cached_interactions/version"

module CachedInteractions
  module Cacheable
    # Method to be implemented in extending interaction
    # @return [CacheStrategy]
    def cache_strategy
      raise NoMethodError
    end

    # @param (see Runnable#initialize)
    #
    # @return [Runnable]
    def run(*args)
      __run__(*args) { super }
    end

    # @param (see Runnable#initialize)
    #
    # @return (see Runnable#run!)
    #
    # @raise (see Runnable#run!)
    def run!(*args)
      __run__(*args) { super }
    end

    def __run__(*args)
      return yield(*args) unless args&.first&.class == Hash

      # Building cache key could make some assumptions on the value types in the args which are incorrect.
      # Log errors with cache key building, and revert to default behavior.
      begin
        key = cache_strategy.key(args.first)
      rescue Exception => e
        Rails.logger.error e.message
        Rails.logger.error e.backtrace.join("\n")
        return yield(*args)
      end

      return yield(*args) if key.nil?

      result = cache_strategy.get(key)
      return result unless result.nil?

      outcome = yield(*args)

      cache_strategy.set(key, outcome) if outcome.valid?
      outcome
    end
  end

  class CacheStrategy
    # @param cache [ActiveSupport::Cache::Store]
    # @param options [Hash] Write options for cache
    # @yield block to build cache key
    #   @yieldparam args [Hash]
    #   @yieldreturn [String]
    def initialize(cache, **options, &block)
      @cache = cache
      @options = options
      @cache_key = block
    end

    # Method to be implemented in extending interaction
    # @param args [Hash]
    # @return [String | Hash]
    def key(args)
      return nil if args.nil? || args[:cacheable_ignore] == true
      @cache_key&.call(args) || args
    end

    # Method to be implemented in extending interaction
    # @param key [String]
    def get(key)
      @cache.fetch(key)
    end

    # Method to be implemented in extending interaction
    # @param key [String]
    # @param outcome [Runnable]
    def set(key, outcome)
      @cache.write(key, outcome, **@options)
    end
  end
end
