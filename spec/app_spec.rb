require 'spec_helper'

describe "boogle" do
  let(:example_data) do
    {
      'pageId' => 300,
      'content' => 'Elementary, dear Watson'
    }.to_json
  end

  let(:example_response) do
    {
      'matches' => [
                    {
                      'pageId' => 300,
                      'score' => 3
                    },

                    {
                      'pageId' => 12,
                      'score' => 1
                    }
                   ]
    }.to_json
  end

  describe "/index" do
    specify "post" do
      post "/index", example_data
      expect(last_response.status).to eq(204)
    end
  end

  describe "/search" do
    specify "get" do
      get "/search?query=Elementary,%20dear%20Watson"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq(example_response)
    end
  end

  def app
    Sinatra::Application
  end
end
