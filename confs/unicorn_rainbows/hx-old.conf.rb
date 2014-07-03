listen "10.0.1.20:8085", :tcp_nopush => true
worker_processes 5 # this should be >= nr_cpus
working_directory "/js/websites/2-ttpod-hx"
pid "/js/pids/unicorn.hx.2.pid"
stderr_path "/js/logs/unicorn.hx.2.stderr.log"
stdout_path "/js/logs/unicorn.hx.2.stdout.log"
