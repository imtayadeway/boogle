require 'sinatra'

get '/search' do
  content_type :json
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

post '/index' do
  content_type :json
  status 204
end
