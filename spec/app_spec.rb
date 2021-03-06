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
    describe "post" do
      after { Page.all.clear }

      it "accepts a request with valid params" do
        post "/index", example_data
        expect(last_response.status).to eq(204)
      end

      it "adds a page" do
        expect {
          post "/index", example_data
        }.to change(Page, :count).by(1)
      end
    end
  end

  describe "/search" do
    describe "get" do
      before :all do
        Page.create('pageId' => 300, 'content' => 'Elementary, dear Watson')
        Page.create('pageId' => 12, 'content' => 'Dear')
      end

      it "returns the results for the search" do
        get "/search?query=Elementary,%20dear%20Watson"
        expect(last_response.status).to eq(200)
        expect(last_response).to be_ok
        expect(last_response.body).to eq(example_response)
      end
    end
  end

  def app
    Sinatra::Application
  end
end
