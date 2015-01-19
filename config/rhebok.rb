# host '127.0.0.1'
# port 8080

# path '/tmp/app.sock'
# backlog 5

# reuseport

max_workers ENV['WEB_CONCURRENCY'] || 2
timeout 15

# max_request_per_child 1000
# min_request_per_child 500

# oobgc false

# max_gc_per_request 5
# min_gc_per_request 3

# spawn_interval 1
