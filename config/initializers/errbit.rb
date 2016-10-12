Airbrake.configure do |config|
  config.host = 'http://192.168.56.2:3001'
  config.project_id = 1 # required, but any positive integer works
  config.project_key = 'a10cf05a53dc090578b75fb20655516c'
  config.environment = Rails.env
  config.ignore_environments = %w(development test)
end
