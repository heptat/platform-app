worker_processes 4
APP_PATH = "/usr/local/www/platform/platform-app"
working_directory APP_PATH
listen 'unix:/tmp/unicorn_platform_app.sock', :backlog => 512
timeout 30
# pid "/var/run/unicorn/platform_app_unicorn.pid"
pid APP_PATH + "/log/unicorn.pid"
# stderr_path APP_PATH + "/log/unicorn.stderr.log"
# stdout_path APP_PATH + "/log/unicorn.stderr.log"

preload_app true
if GC.respond_to?(:copy_on_write_friendly=)
  GC.copy_on_write_friendly = true
end

before_fork do |server, worker|
  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end
