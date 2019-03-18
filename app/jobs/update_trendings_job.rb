class UpdateTrendingsJob < ApplicationJob # >
  queue_as :trendings

  def perform
    hashtags = {}
    DataStore.redis.scan_each(match: '#*').each do |hashtag|
      hashtags[hashtag] = DataStore.redis.get(hashtag)
    end

    @trending = Trending.new(hashtags: hashtags.sort_by(&:last).reverse[0..4])

    if @trending.save
      hashtags.each do |hashtag|
        DataStore.redis.del(hashtag.first)
      end
    else
      raise "Failed to update Trendings: #{@trending.errors.full_messages}"
    end
  end
end