# Rakefile
require "sinatra"
require "sinatra/activerecord"
require "sinatra/activerecord/rake"

Dir.glob('./models/*.rb').each { |r| require r } 
Dir.glob('lib/*.rake').each { |r| load r}

namespace :db do
  task :load_config do
    require "./app"
  end
end
