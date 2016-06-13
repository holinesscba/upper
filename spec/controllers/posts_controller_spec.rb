require 'rails_helper'

RSpec.describe PostsController do
  describe 'GET #index' do
    it 'returns a 200 status code' do
      get :index
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET #new' do
    it 'returns a 200 status code' do
      get :new
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST #create' do
    let(:format) { :json }

    let(:post_service)  { double }
    let(:fake_post)     { instance_double('Post', to_model: Post.new, errors: []) }

    before do
      allow(controller).to receive(:post_service) { post_service }
      allow(post_service).to receive(:build) { fake_post }
    end

    context 'with valid params' do
      before do
        allow(fake_post).to receive(:save) { true }
      end

      let(:valid_post_params) { Hash.new }

      it 'returns a 201 status code' do
        post :create, valid_post_params.merge(format: format)

        expect(response).to have_http_status(201)
      end
    end

    context 'with invalid params' do
      before do
        allow(fake_post).to receive(:save) { false }
      end

      let(:invalid_post_params) { Hash.new }

      it 'returns a 422 status code' do
        pos :create, invalid_post_params.merge(format: format)

        expect(response).to have_http_status(422)
      end
    end
  end
end
