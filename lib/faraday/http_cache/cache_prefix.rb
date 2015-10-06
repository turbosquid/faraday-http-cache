module Faraday
  module CachePrefix
    def prefix
      (@serializer.is_a?(Module) ? @serializer : @serializer.class).name
    end
  end
end
 
