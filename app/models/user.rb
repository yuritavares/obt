class User < ApplicationRecord # >
  mount_base64_uploader :photo, PhotoUploader
  has_secure_password
  validates_length_of :password,
                      minimum: 8,
                      maximum: 72,
                      allow_nil: true,
                      allow_blank: false

  validates_presence_of :name, :email

  acts_as_voter
  acts_as_followable
  acts_as_follower
  has_many :tweets, dependent: :destroy

  searchkick
  
  def search_data
    { name: name, email: email }
  end

  def timeline
    timeline = self.tweets.map { |tweet| tweet }
    all_following.each do |user|
      timeline += user.tweets.map { |tweet| tweet }
    end
    timeline.sort_by!(&:created_at).reverse
  end
end
