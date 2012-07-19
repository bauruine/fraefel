# unicorn config file based on github config
# customnized by Stefan Spühler for i-v-o.ch
rails_env = 'development'

# 16 workers and 1 master
worker_processes 1

# Load rails+github.git into the master before forking workers
# for super-fast worker spawn times
#preload_app true

# Restart any workers that haven't responded in 30 seconds
timeout 900

# change this for other apps
approot = '/home/parallels/Code/rails/fraefel/'
#appuser = 'fraefel'
# Listen on a Unix data socket
listen 3000
# path to pid file
pid "#{approot}/tmp/pids/app.pid"
stderr_path "#{approot}/log/unicorn_error.log"
stdout_path "#{approot}/log/unicorn_message.log"
