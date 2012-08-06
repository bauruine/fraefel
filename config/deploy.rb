# USAGE: 
#   setup   to staging    server: cap deploy:setup
#   setup   to production server: cap deploy:setup deploy="production"
#   deploy  to staging    server: cap deploy
#   deploy  to production server: cap deploy deploy="production"
#   feed staging server with production db: cap feed_staging deploy=production

#load database.yml generator
# TODO: none
require File.dirname(__FILE__) + "/capistrano_database_yml.rb"
require "highline/import"
# needs to be before bundler 
set :bundle_flags,    "--deployment --quiet --binstubs"
require 'bundler/capistrano'
# require 'lib/cap_tasks'
# Uncomment if you are using Rails' asset pipeline
load 'deploy/assets'
# use rbenv environment

set :application, "FRAEFEL"
set :repository,  "git@github.com:innovative-office/fraefel.git"
set :branch,  "master"
set :scm, :git

# STAGING / PRODUCTION
if ENV['deploy'] == 'production' # production only if explicitly asked to do
  puts "\n\n*** working with PRODUCTION server! ***\n\n"
  set :deploy_to, "/var/www/fraefel/app/"
  ssh_options[:username] = "fraefel"
  set :default_environment, {
    'PATH' => "/var/www/fraefel/.rbenv/shims:/var/www/fraefel/.rbenv/bin:$PATH"
  }
else # do the dino... staging
  puts "\n\n*** working with STAGING server! *** \n\n"
  set :deploy_to, "/var/www/fraefel_staging/app/"
  ssh_options[:username] = "fraefel_staging"
  set :default_environment, {
    'PATH' => "/var/www/fraefel_staging/.rbenv/shims:/var/www/fraefel_staging/.rbenv/bin:$PATH"
  }
end

# ask if sure to continue?
answer = Capistrano::CLI.ui.ask("Do you want to continue? Type 'y' to continue")

if answer == 'y' then
  # continue 
else
  Process.exit!
end


# ssh options
ssh_options[:forward_agent] = true

#other server dependent options
default_run_options[:pty] = true
set :use_sudo, false # NOTE: should be true by default

# cache the app (don't do a full clone on every update)
set :deploy_via, :remote_cache

if ENV['deploy'] != 'production' # just on staging
	after "deploy", "feed_staging"
end


# migration of the database
after "deploy", "deploy:migrate"

# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
if ENV['deploy'] == 'production' # production only if explicitly asked to do
server "fraefel.i-v-o.ch", :app, :web, :db, :primary => true
else 
server "fraefel.i-v-o.ch", :app, :web, :db, :primary => true
end


# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
if ENV['deploy'] == 'production' # production only if explicitly asked to do
	set :unicorn_init_script, "/etc/init.d/fraefel_app"
else
	set :unicorn_init_script, "/etc/init.d/fraefel_staging_app"
end
namespace :deploy do
        task :start, :roles => :app, :except => { :no_release => true } do
                # run "#{try_sudo} #{unicorn_init_script} start"
                run "#{unicorn_init_script} start"
        end
        task :stop, :roles => :app, :except => { :no_release => true } do
                run "#{try_sudo} #{unicorn_init_script} stop"
        end
# ugly hack
        task :restart, :roles => :app, :except => { :no_release => true } do
                run "#{try_sudo} #{unicorn_init_script} stop"
		sleep 3
                run "#{try_sudo} #{unicorn_init_script} start"
        end
end

######################
#### custom tasks ####
#####################


desc "feeds staging with production data"
task :feed_staging, :role => :db, :only => { :primary => true } do 
  puts "hey! I am a feeder"
  
  staging_database = "fraefel_production_staging"
  staging_db_pw = Capistrano::CLI.ui.ask("Enter MySQL root password for Staging(db:#{staging_database} : ")

  # load backup in
  load_commands = "mysql #{staging_database} -u root --password=#{staging_db_pw} < /media/backup/fraefel_production.dump"

  # TODO: run command
  run load_commands do |ch, stream, out|
    puts out
  end
end




