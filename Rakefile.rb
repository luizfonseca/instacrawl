# Rakefile
require "sinatra"
require "sinatra/activerecord"
require "sinatra/activerecord/rake"
set :database, { adapter: "sqlite3", database: "database.sqlite3" }

Dir.glob('./models/*.rb').each { |r| require r } 
Dir.glob('lib/*.rake').each { |r| load r}

namespace :db do
  task :load_config do
    require "./app"
  end
end
