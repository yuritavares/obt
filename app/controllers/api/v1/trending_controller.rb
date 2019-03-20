module Api
  module V1
    class TrendingController < ApplicationController
      def index
        @trendings = Trending.last
        render json: @trendings
      end
    end
  end
end