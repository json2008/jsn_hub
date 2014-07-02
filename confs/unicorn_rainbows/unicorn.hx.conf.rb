# listen 8082 # by default Unicorn listens on port 8080
# listen "/tmp/.sock", :backlog => 64
listen "localhost:8082", :tcp_nopush => true
worker_processes 50 # this should be >= nr_cpus
working_directory "/js/websites/3-ttpod-hx"
pid "/js/pids/unicorn.hx.3.pid"
stderr_path "/js/logs/unicorn.hx.3.stderr.log"
stdout_path "/js/logs/unicorn.hx.3.stdout.log"
