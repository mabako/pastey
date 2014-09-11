require 'sinatra'
require 'redis'
require 'json'

configure do
  REDIS = Redis.new(url: 'redis://localhost:6379/3')
  EXPIRE_IN = 60 * 60 * 24 * 3 # 3 days
end

get '/:paste' do
  paste = REDIS.get(params[:paste])

  # some random unknown paste. not our problem.
  pass if paste.nil?

  content_type :text
  paste
end

post '/' do
  data = params[:data]

  # only relevant if there's some content
  pass if data.nil? || data.length == 0

  # generate some random 4 char id and persist it for a while
  id = rand(36**4).to_s(36)
  REDIS.set(id, data)
  REDIS.expire(id, EXPIRE_IN)

  content_type :json
  { id: id }.to_json
end

not_found do
  halt 404, ''
end
