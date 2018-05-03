require 'rails_helper'

RSpec.describe ActivityPub::OutboxesController, type: :controller do
  let!(:account) { Fabricate(:account) }

  before do
    Fabricate(:status, account: account)
  end

  describe 'GET #show for routing version v1' do
    before do
      get :show, params: { account_type: 'v1_trainer', account_username: account.username }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'returns application/activity+json' do
      expect(response.content_type).to eq 'application/activity+json'
    end
  end

  describe 'GET #show for routing version v2' do
    before do
      get :show, params: { account_type: 'trainer', account_no: account.trainer_no }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'returns application/activity+json' do
      expect(response.content_type).to eq 'application/activity+json'
    end
  end
end
