class AddHashtagsJob < ApplicationJob # >
  queue_as :trendings

  def perform(tweet)
    tweet.scan(/#\w+/).each do |hashtag|
      hashtag_count = DataStore.redis.get(hashtag)
      DataStore.redis.set(hashtag, ((hashtag_count)? hashtag_count.to_i + 1 : 1))
    end
  end
end