module Faraday
  class HttpCache < Faraday::Middleware
    # Internal: A class to represent a request
    class Request
      class << self
        def from_env(env, options = {})
          hash = env.to_hash
          new(method: hash[:method], url: hash[:url], body: hash[:body], headers: hash[:request_headers].dup, serializer: options[:serializer])
        end
      end

      attr_reader :method, :url, :headers, :body

      def initialize(options)
        @method, @url, @headers, @body = options.values_at(:method, :url, :headers, :body)
        @serializer = options[:serializer] || Faraday::HttpCache.default_serializer
      end

      # Internal: Validates if the current request method is valid for caching.
      #
      # Returns true if the method is ':get' or ':head'.
      def cacheable?
        return false if method != :get && method != :head
        return false if cache_control.no_store?
        true
      end

      # Computes the cache key for this request instance, accountng for the
      # current serializer to avoid cross serialization issues.
      #
      # Returns a String.
      def cache_key
        prefix = (@serializer.is_a?(Module) ? @serializer : @serializer.class).name
        Faraday::HttpCache.cache_key(prefix, @url, @body)
      end

      def no_cache?
        cache_control.no_cache?
      end

      # Internal: Gets the 'CacheControl' object.
      def cache_control
        @cache_control ||= CacheControl.new(headers['Cache-Control'])
      end

      def serializable_hash
        {
          method: @method,
          url: @url,
          headers: @headers,
          body: @body
        }
      end
    end
  end
end
