require 'redis'

module DataStore
  def self.redis
    @redis ||= Redis.new(url: 'redis://localhost:6379/0')
  end
end
