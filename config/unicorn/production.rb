worker_processes 3
timeout 60
preload_app true

root = "/home/deploy/bdcesium/current"
working_directory "/home/deploy/bdcesium/current"
pid "#{root}/tmp/pids/unicorn.pid"

listen "/tmp/unicorn.bdcesium.sock", :backlog => 64

stderr_path "/home/deploy/bdcesium/shared/log/unicorn.stderr.log"
stdout_path "/home/deploy/bdcesium/shared/log/unicorn.stdout.log"

GC.copy_on_write_friendly = true if GC.respond_to?(:copy_on_write_friendly=)

before_fork do |server, worker|
  ActiveRecord::Base.connection.disconnect!
  old_pid = "#{root}/tmp/pids/unicorn.pid.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection
end
