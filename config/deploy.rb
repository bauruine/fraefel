# USAGE: 
#   setup   to staging    server: cap deploy:setup
#   setup   to production server: cap deploy:setup deploy="production"
#   deploy  to staging    server: cap deploy
#   deploy  to production server: cap deploy deploy="production"
#   feed staging server with production db: cap feed_staging deploy=production

#load database.yml generator
# TODO: none
require "config/capistrano_database_yml.rb"
require "highline/import"
# needs to be before bundler 
set :bundle_flags,    "--deployment --quiet --binstubs"
require 'bundler/capistrano'
# require 'lib/cap_tasks'

# use rbenv environment
set :default_environment, {
  'PATH' => "/var/www/fraefel/.rbenv/shims:/var/www/fraefel/.rbenv/bin:$PATH"
}


set :application, "IVO::DEMO"
set :repository,  "git@github.com:innovative-office/ivo-corp.git"
set :branch,  "master"
set :scm, :git

# STAGING / PRODUCTION
if ENV['deploy'] == 'production' # production only if explicitly asked to do
  puts "\n\n*** working with PRODUCTION server! ***\n\n"
  set :deploy_to, "/var/www/fraefel/app/"
else # do the dino... staging
  puts "\n\n*** working with STAGING server! *** \n\n"
  set :deploy_to, "/var/www/fraefel/app/"
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
ssh_options[:username] = "fraefel"

#other server dependent options
default_run_options[:pty] = true
set :use_sudo, false # NOTE: should be true by default

# cache the app (don't do a full clone on every update)
set :deploy_via, :remote_cache

# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
if ENV['deploy'] == 'production' # production only if explicitly asked to do
server "5.9.2.105", :app, :web, :db, :primary => true
#server "srvcluster2.i-v-o.ch", :app, :web, :db
else 
server "192.168.56.20", :app, :web, :db, :primary => true
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

set :unicorn_init_script, "/etc/init.d/fraefel_app"
namespace :deploy do
        task :start, :roles => :app, :except => { :no_release => true } do
                # run "#{try_sudo} #{unicorn_init_script} start"
                run "#{unicorn_init_script} start"
        end
        task :stop, :roles => :app, :except => { :no_release => true } do
                run "#{try_sudo} #{unicorn_init_script} stop"
        end
=begin
        task :graceful_stop, :roles => :app, :except => { :no_release => true } do
                run "#{try_sudo} #{unicorn_init_script} winch"
          run "#{try_sudo} kill -s QUIT `cat #{unicorn_pid}`"
        end
=end
        task :restart, :roles => :app, :except => { :no_release => true } do
                run "#{try_sudo} #{unicorn_init_script} upgrade"
        end
end

######################
#### custom tasks ####
#####################


desc "feeds staging with production data"
task :feed_staging, :role => :db, :only => { :primary => true } do 
  puts "hey! I am a feeder"

  ########### connect to production
  #NOTE: done by capistrano set(:deploy_to)

  ########### backup 
  
  # backup db
  say("<%= color('dump db', :yellow) %>")
  db.backup

  # (backup production FILES) NOTE: optional
  

  ########### feed staging

  say("<%= color('start feeding', :yellow) %>")
    # connect
=begin
    send_to = File.join(deploy_to, "production_dumps")
    file_to_be_send = File.join(deploy_to, "backups", "/current_#{application}.backup.sql.bz2")
    target_file = File.join(send_to, "#{application}.dump.#{Time.now.to_i}.sql.bz2")
    
    #
    copy_command = %Q{
      mkdir -p #{send_to} && rsync -e ssh -av -L --rsh='ssh -p2122' #{file_to_be_send} ivo@i-v-o.ch:~/
    }
    run copy_command do |ch, stream, out|
      puts out
    end
    # connect to production 
    connect_to_production
    # load dump into db
=end
  # NOTE: static, for more security
  staging_server_intern_ip = "192.168.56.102"
  staging_database = "ivo_v2_production_staging"
  # ask again:
  answer = Capistrano::CLI.ui.ask("Do you really want to drop #{staging_database} on #{staging_server_intern_ip}? Type 'y' to continue")

  if answer == 'y' then
    # continue 
  else
    Process.exit!
  end

  staging_db_pw = Capistrano::CLI.ui.ask("Enter MySQL database user password for Staging(db:#{staging_database} : ")

=begin
  # drop dbs 
  drop_commands = "mysqldump -u root --password=#{staging_db_pw} --add-drop-table --no-data #{staging_database} -h #{staging_server_intern_ip} | grep ^DROP | mysql -u root --password=#{staging_db_pw} #{staging_database} -h #{staging_server_intern_ip}"
  # TODO: run command
  run drop_commands do |ch, stream, out|
    puts out
  end
=end

  # load backup in
  load_commands = "mysql #{staging_database} -h #{staging_server_intern_ip} -u root --password=#{staging_db_pw} < #{deploy_to}/backups/current_#{application}.backup.sql"

  # TODO: run command
  run load_commands do |ch, stream, out|
    puts out
  end


end

#NOTE: done
namespace :db do
  desc "Backup the remote production database."
  task :backup, :roles => :db, :only => { :primary => true } do
    backup_to = File.join(deploy_to, "backups")
    backup_file = File.join(backup_to, "#{application}.backup.#{Time.now.to_i}.sql")
    # NOTE: commented next line. usefull if it stays
    # on_rollback { delete backup_file }
    # db = YAML::load(ERB.new(IO.read(File.join(File.dirname(__FILE__), 'database.yml'))).result)['development']
    # TODO: ask for pw
    database_name =     "ivo_development" #Capistrano::CLI.ui.ask("Enter MySQL database name: ")
    database_user =     "root" # Capistrano::CLI.ui.ask("Enter MySQL database user: ")
    database_password = "ubuntuGV08ivo" # Capistrano::CLI.ui.ask("Enter MySQL database password: ")
    # make file, bzip it & make symlink to newest
    commands = %Q{
      mkdir -p #{backup_to} && mysqldump --user=#{database_user} --password=#{database_password} #{database_name} | bzip2 -c > #{backup_file}.bz2 && rm -f #{backup_to}/current_#{application}.backup.sql.bz2 && ln -s #{backup_file} #{backup_to}/current_#{application}.backup.sql.bz2 && mysqldump --user=#{database_user} --password=#{database_password} #{database_name} > #{backup_file} && rm -f #{backup_to}/current_#{application}.backup.sql && ln -s #{backup_file} #{backup_to}/current_#{application}.backup.sql   
    }
    run commands do |ch, stream, out|
      puts out
    end
  end
end

desc "test explicit connection to production"
task :connect_to_production, :roles => :staging do
    set :port, 22
    #ivo_prod = Capistrano::ServerDefinition.new("ivo@i-v-o.ch:22")
    #ssh_session = Capistrano::SSH.connect(ivo_prod)
    testcommands = %Q{
      cd /home/ivo/ && mkdir -p "testconnect"
       }
    run testcommands do |ch, stream, out|
      puts out
    end
 end
