module Api
    module V1
      class UserTokenController < Knock::AuthTokenController
        include Knock::Authenticable
      end
    end
  end