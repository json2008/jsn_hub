
# listen "/tmp/.sock", :backlog => 64
# listen "localhost:8082", :tcp_nopush => true
listen 8080
worker_processes 2 # this should be >= nr_cpus
working_directory "/js/websites/rbs"
pid "/js/pids/rbs.pid"
stderr_path "/js/logs/rbs.stderr.log"
stdout_path "/js/logs/rbs.stdout.log"

Rainbows! do
  use :ThreadSpawn # concurrency model to use
  worker_connections 100
  keepalive_timeout 30 # zero disables keepalives entirely
  client_max_body_size 5*1024*1024 # 5 megabytes
  keepalive_requests 100 # default:100
  client_header_buffer_size 2 * 1024 # 2 kilobytes
end

#=============
# mkdir tmp
# mkdir tmp/sockets
# mkdir tmp/pids
# mkdir log
#=============
# set path to app that will be used to configure unicorn,
# note the trailing slash in this example
@dir = "/path/to/app/"

worker_processes 2
working_directory @dir

timeout 30

# Specify path to socket unicorn listens to,
# we will use this in our nginx.conf later
listen "#{@dir}tmp/sockets/unicorn.sock", :backlog => 64

# Set process id path
pid "#{@dir}tmp/pids/unicorn.pid"

# Set log file paths
stderr_path "#{@dir}log/unicorn.stderr.log"
stdout_path "#{@dir}log/unicorn.stdout.log"
