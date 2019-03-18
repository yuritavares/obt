class AddHashtagsJob < ApplicationJob # >
  queue_as :trendings

  def perform(tweet)
    tweet.scan(/#\w+/).each do |hashtag|
      h = DataStore.redis.get(hashtag)
      DataStore.redis.set(hashtag, ((h)? h.to_i + 1 : 1))
    end
  end
end