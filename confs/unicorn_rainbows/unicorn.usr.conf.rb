# listen 8082 # by default Unicorn listens on port 8080
# listen "/tmp/.sock", :backlog => 64
listen "10.0.1.13:8084", :tcp_nopush => true
worker_processes 50 # this should be >= nr_cpus
working_directory "/js/websites/ttus.ttpod.com"
pid "/js/pids/unicorn.usr.pid"
stderr_path "/js/logs/unicorn.usr.stderr.log"
stdout_path "/js/logs/unicorn.usr.stdout.log"
