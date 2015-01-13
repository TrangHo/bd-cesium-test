# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'bdcesium'
set :repo_url, 'git@github.com:TrangHo/bd-cesium-test.git'
set :unicorn_pid, "#{shared_path}/pids/unicorn.pid"
set :scm, :git
set :use_sudo, true
set :rvm_ruby_version, 'ruby-2.1.1'


# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :default_env, { path: "/usr/local/rvm/gems/ruby-2.1.1/bin:$PATH" }

set :keep_releases, 5
set :delayed_job_server_role, :worker
set :delayed_job_args, "-n 2"

namespace :deploy do

  %w[start stop restart].each do |command|
    desc "#{command} unicorn server"
    task command do
      on roles(:app), except: { no_release: true } do
        execute "chmod +x /etc/init.d/unicorn_#{fetch(:application)}"
        if command == 'restart'
          execute "sudo -s /etc/init.d/unicorn_#{fetch(:application)} stop #{fetch(:rails_env)}"
          execute "sudo -s /etc/init.d/unicorn_#{fetch(:application)} start #{fetch(:rails_env)}"
        else
          execute "sudo -s /etc/init.d/unicorn_#{fetch(:application)} #{command} #{fetch(:rails_env)}"
        end
        execute "sudo nginx -s reload"
      end
    end
  end

  task :setup_config do
    on roles(:app) do
      app_root = "#{deploy_to}/current"
      unicorn_user = fetch(:unicorn_user)

      execute "mkdir -p #{shared_path}/config"

      nginx_conf = StringIO.new(ERB.new(File.read("./config/nginx.conf.erb")).result(binding))
      upload! nginx_conf, "#{shared_path}/config/nginx.conf"
      sudo "ln -nfs #{shared_path}/config/nginx.conf /etc/nginx/sites-enabled/#{fetch(:application)}"

      unicorn_sh = StringIO.new(ERB.new(File.read("./config/unicorn.sh.erb")).result(binding))
      upload! unicorn_sh, "#{shared_path}/config/unicorn.sh"
      sudo "ln -nfs #{shared_path}/config/unicorn.sh /etc/init.d/unicorn_#{fetch(:application)}"
    end
  end

  task :symlink_config do
    on roles(:app) do
      execute "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
      execute "ln -s #{shared_path}/tmp #{release_path}/tmp"
      execute "ln -s #{shared_path}/log #{release_path}/log"
    end
  end

  after :publishing, :restart
  after :updating, :setup_config
  after :updating, :symlink_config

end

after "deploy", "deploy:cleanup"
