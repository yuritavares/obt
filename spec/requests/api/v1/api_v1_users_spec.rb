require 'rails_helper'
require 'rspec/json_expectations'

RSpec.describe 'Api::V1::Users', type: :request do
  describe 'GET /api/v1/users/:id' do
    context 'when user exists' do
      let(:user) { create(:user) }
      let(:following_number) { Random.rand(9) }
      let(:followers_number) { Random.rand(9) }
      let(:tweet_number) { Random.rand(9) }

      before do
        followers_number.times { create(:user).follow(user) }
        following_number.times { user.follow(create(:user)) }
        tweet_number.times { create(:tweet, user: user) }

        get "/api/v1/users/#{user.id}"
      end

      it { expect(response).to have_http_status(:success) }

      it 'returns valid user in json' do
        expect(json).to eql(serialized(Api::V1::UserSerializer, user))
      end

      it 'followers number' do
        expect(json['followers_count']).to eql(followers_number)
      end

      it 'following number' do
        expect(json['following_count']).to eql(following_number)
      end

      it 'tweets number' do
        expect(json['tweets_count']).to eql(tweet_number)
      end
    end

    context 'when user dont exist' do
      let(:user_id) { -1 }

      before { get "/api/v1/users/#{user_id}" }

      it { expect(response).to have_http_status(:not_found) }
    end
  end

  describe 'GET /api/v1/users/current' do
    context 'Unauthenticated' do
      it_behaves_like :deny_without_authorization, :get, '/api/v1/users/current'
    end

    context 'Authenticated' do
      let(:user) { create(:user) }
      let(:following_number) { Random.rand(9) }
      let(:followers_number) { Random.rand(9) }
      let(:tweet_number) { Random.rand(9) }

      before do
        followers_number.times { create(:user).follow(user) }
        following_number.times { user.follow(create(:user)) }
        tweet_number.times { create(:tweet, user: user) }

        get '/api/v1/users/current', headers: header_with_authentication(user)
      end

      it { expect(response).to have_http_status(:success) }

      it 'returns valid user in json' do
        expect(json).to eql(serialized(Api::V1::UserSerializer, user))
      end

      it 'Right followers number' do
        expect(json['followers_count']).to eql(followers_number)
      end

      it 'Right following number' do
        expect(json['following_count']).to eql(following_number)
      end

      it 'Right tweets number' do
        expect(json['tweets_count']).to eql(tweet_number)
      end
    end
  end

  describe 'DELETE /api/v1/users/:id' do
    context 'Unauthenticated' do
      it_behaves_like :deny_without_authorization, :delete, '/api/v1/users/-1'
    end

    context 'Authenticated' do
      context 'User exists' do
        context 'Owner of resource' do
          before { @user = create(:user) }

          it do
            delete "/api/v1/users/#{@user.id}", headers: header_with_authentication(@user)
            expect(response).to have_http_status(:no_content)
          end

          it 'delete user' do
            expect do
              delete "/api/v1/users/#{@user.id}", headers: header_with_authentication(@user)
            end.to change { User.count }.by(-1)
          end
        end

        context 'Not resource owner' do
          let(:user) { create(:user) }

          let(:other_user) { create(:user) }

          before do
            delete "/api/v1/users/#{other_user.id}", headers: header_with_authentication(user)
          end

          it { expect(response).to have_http_status(:forbidden) }
        end
      end

      context 'User dont exist' do
        let(:user) { create(:user) }
        let(:user_id) { -1 }

        before { delete "/api/v1/users/#{user_id}", headers: header_with_authentication(user) }

        it { expect(response).to have_http_status(:not_found) }
      end
    end
  end

  describe 'POST /api/v1/users' do
    context 'Valid params' do
      let(:user_params) { attributes_for(:user) }

      it 'return created' do
        post '/api/v1/users/', params: { user: user_params }
        expect(response).to have_http_status(:created)
      end

      it 'returns right user in json' do
        post '/api/v1/users/', params: { user: user_params }
        expect(json).to include_json(user_params.except(:password))
      end

      it 'create user' do
        expect do
          post '/api/v1/users/', params: { user: user_params }
        end.to change { User.count }.by(1)
      end
    end

    context 'Invalid params' do
      let(:user_params) { { foo: :bar } }

      before { post '/api/v1/users/', params: { user: user_params } }

      it { expect(response).to have_http_status(:unprocessable_entity) }
    end
  end

  describe 'PUT /api/v1/users/:id' do
    context 'Unauthenticated' do
      it_behaves_like :deny_without_authorization, :put, '/api/v1/users/-1'
    end

    context 'Authenticated' do
      context 'Resource owner' do
        context 'Valid params' do
          let(:user) { create(:user) }
          let(:user_params) { attributes_for(:user) }

          before do
            put "/api/v1/users/#{user.id}", params: { user: user_params }, headers: header_with_authentication(user)
          end

          it { expect(response).to have_http_status(:success) }

          it 'returns json with user updated' do
            expect(json).to include_json(user_params.except(:password))
          end
        end

        context 'Invalid params' do
          let(:user_params) { { foo: :bar } }

          before { post '/api/v1/users/', params: { user: user_params } }

          it { expect(response).to have_http_status(:unprocessable_entity) }
        end
      end

      context 'Not resource owner' do
        let(:user) { create(:user) }
        let(:other_user) { create(:user) }
        let(:user_params) { attributes_for(:user) }

        before do
          put "/api/v1/users/#{other_user.id}", params: { user: user_params }, headers: header_with_authentication(user)
        end

        it { expect(response).to have_http_status(:forbidden) }
      end
    end
  end

  describe 'GET /api/v1/users/:id/following?page=:page' do
    context 'User exists' do
      let(:user) { create(:user) }
      let(:following_number) { Random.rand(15..25) }

      before { following_number.times { user.follow(create(:user)) } }

      it do
        get "/api/v1/users/#{user.id}/following?page=1"
        expect(response).to have_http_status(:success)
      end

      it 'returns right following' do
        get "/api/v1/users/#{user.id}/following?page=1"

        expect(json).to eql(each_serialized(Api::V1::UserSerializer, user.following_users[0..14]))
      end

      it 'returns 15 elemments on first page' do
        get "/api/v1/users/#{user.id}/following?page=1"
        expect(json.count).to eql(15)
      end

      it 'returns remaining elemments on second page' do
        get "/api/v1/users/#{user.id}/following?page=2"
        remaining = user.following_users.count - 15
        expect(json.count).to eql(remaining)
      end
    end

    context 'User dont exist' do
      let(:user_id) { -1 }

      before { get "/api/v1/users/#{user_id}/following" }

      it { expect(response).to have_http_status(:not_found) }
    end
  end

  describe 'GET /api/v1/users/:id/followers?page=:page' do
    context 'User exists' do
      let(:user) { create(:user) }
      let(:followers_number) { Random.rand(15..25) }

      before { followers_number.times { create(:user).follow(user) } }

      it do
        get "/api/v1/users/#{user.id}/followers?page=1"
        expect(response).to have_http_status(:success)
      end

      it 'returns right followers' do
        get "/api/v1/users/#{user.id}/followers?page=1"
        expect(json).to eql(each_serialized(Api::V1::UserSerializer, user.followers[0..14]))
      end

      it 'returns 15 elemments on first page' do
        get "/api/v1/users/#{user.id}/followers?page=1"
        expect(json.count).to eql(15)
      end

      it 'returns remaining elemments on second page' do
        get "/api/v1/users/#{user.id}/followers?page=2"
        remaining = user.followers.count - 15
        expect(json.count).to eql(remaining)
      end
    end

    context 'User dont exist' do
      let(:user_id) { -1 }

      before { get "/api/v1/users/#{user_id}/followers" }

      it { expect(response).to have_http_status(:not_found) }
    end
  end
end
