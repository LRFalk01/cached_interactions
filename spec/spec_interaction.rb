module SpecInteraction
  class HashStore
    def initialize
      @cache = {}
    end

    def fetch(key, **options)
      result = @cache[key]
      return result unless result.nil?

      return nil unless block_given?

      result = yield
      @cache[key] = result
    end

    def write(key, value, **options)
      @cache[key] = value
    end
  end

  class CachedInteraction < ActiveInteraction::Base
    extend CachedInteractions::Cacheable
    integer :id

    def execute
      # puts 'executing'
      'testing'
    end

    @cache_strategy = CachedInteractions::CacheStrategy.new(
      HashStore.new,
      expires_in: 15, skip_nil: true
    ) do |args|
      args[:id]
    end

    def self.cache_strategy
      @cache_strategy
    end
  end


  class StandardInteraction < ActiveInteraction::Base
    @@cache = HashStore.new
    integer :id

    def execute
      result = @@cache.fetch(id, expires_in: 15, skip_nil: true) do
        'testing'
      end
      # puts 'executing'
      result
    end
  end
end
