class User < ApplicationRecord #>
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
end