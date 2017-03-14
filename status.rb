require 'sinatra'

configure do
  set :views, "#{File.dirname(__FILE__)}/views"
end

get '/' do
  @title = "Xplenty SSH Tunnel Status"
  
  @pid = (File.read(File.join(ENV["HOME"], '.heroku', 'autossh.pid')) rescue nil).to_i
  if @pid > 0
    @status = "healthy"
    @status_class= "text-success"
  else
    @status = "not working"
    @status_class= "text-danger"
  end
  @logs = File.read(File.join(ENV["HOME"], '.heroku', 'tunnel.log'))
  @command = File.read(File.join(ENV["HOME"], '.heroku', 'tunnel.cmd'))
  erb :status
end