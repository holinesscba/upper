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

    before do
      allow_any_instance_of(Post).to receive(:read_gmail)
      allow_any_instance_of(Post).to receive(:post_wordpress)
    end

    context 'with valid params' do
      let(:valid_post_params) do
        Hash[post: {
          title: 'some title',
          file: 'filename.pdf'
        }]
      end

      it 'returns a 201 status code' do
        post :create, valid_post_params.merge(format: format)

        expect(response).to have_http_status(201)
      end
    end

    context 'with invalid params' do
      let(:invalid_post_params) do
        Hash[post: {
          title: '',
          file: ''
        }]
      end

      it 'returns a 422 status code' do
        post :create, invalid_post_params.merge(format: format)

        expect(response).to have_http_status(422)
      end
    end
  end
end
