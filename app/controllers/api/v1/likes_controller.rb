module Api
  module V1
    class LikesController < Api::V1::ApiController # >
      before_action :set_tweet
      before_action :authenticate_user

      def create
        if current_user.likes @tweet
          render json: { msg: 'Liked with success' }, status: :created
        else
          render json: { errors: 'Problems to like' }, status: :unprocessable_entity
        end
      end

      def destroy
        current_user.dislikes @tweet
      end

      private

      def set_tweet
        @tweet = Tweet.find(params[:id])
      end
    end
  end
end
