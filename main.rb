require 'sinatra'
require 'pg'
require 'sequel'
require 'logger'

get '/' do
  random_string = "Hello"

  # you can set `TEST_TEST` environment variable in AppService Application settings to see if you can access it from container
  "#{random_string} from Dockerized Ruby - #{Time.now.to_i}; #{ENV['TEST_TEST']}"
end

get '/db' do
  # variables that are specific to your "Azure Database for Postgres", Don't commit changes !
  server_admin_login_name = ENV['PG_USER']  # eg: myuser@mydatabasename
  server_name = ENV['PG_HOST']              # eg: mydatabasename.postgres.database.azure.com
  password = ENV['PG_PASS']

  # ...remaining values are constant. Read more: https://docs.microsoft.com/en-us/azure/postgresql/quickstart-create-server-database-portal
  DB = Sequel.connect(
    adapter: :postgres,
    user: server_admin_login_name,
    password: password,
    host: server_name,
    port: 5432,
    database: 'postgres',
    max_connections: 10,
    logger: Logger.new(STDOUT))

  if DB.test_connection
    "connection success"
  else
    "connection error"
  end
end
