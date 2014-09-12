require 'sinatra'
require 'redis'
require 'json'
require 'slim'

configure do
  REDIS = Redis.new(url: 'redis://localhost:6379/3')
  EXPIRE_IN = 60 * 60 * 24 * 3 # 3 days
end

# Retrieve any paste by ID
get '/:paste' do
  paste = REDIS.get(params[:paste])

  # some random unknown paste. not our problem, just drops to the not_found
  # handler usually
  pass if paste.nil?

  content_type :text
  paste
end

# post to this site
post '/' do
  data = params[:data]

  # only relevant if there's some content
  pass if data.nil? || data.length == 0

  # generate some random 4 char id and persist it for a while
  id = rand(36**4).to_s(36)
  REDIS.set(id, data)
  REDIS.expire(id, EXPIRE_IN)

  # if we have 'redirect' set to true, just redirect to the page
  if params[:redirect]
    redirect to('/' + id)
  else # output the JSON file
    content_type :json
    { id: id }.to_json
  end
end

# render a simple form
get '/' do
  slim :zen
end

not_found do
  halt 404, ''
end
