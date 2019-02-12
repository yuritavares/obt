module Api
  module V1
    class FollowsController < Api::V1::ApiController # >
      before_action :set_user
      before_action :authenticate_user

      def create
        if current_user.follow(@user)
          render json: { msg: 'User followed with success' }, status: :created
        else
          render json: { errors: 'Problems to follow user' }, status: :unprocessable_entity
        end
      end

      def destroy
        if current_user.stop_following(@user)
          render json: { msg: 'User unfollowed with success' }
        else
          render json: { errors: 'Problems to unfollow user' }, status: :unprocessable_entity
        end
      end

      private

      def set_user
        @user = User.find(params[:id])
      end
    end
  end
end
