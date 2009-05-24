set :application, "railscasts.com"
set :server_name, "ec2-79-125-57-198.eu-west-1.compute.amazonaws.com"
role :app, server_name
role :web, server_name
role :db,  server_name, :primary => true

set :user, "deploy"
set :deploy_to, "/srv/www/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, "git"
set :repository, "git://github.com/mattmatt/railscasts.git"
set :branch, "master"

namespace :deploy do
  desc "Tell Passenger to restart."
  task :restart, :roles => :web do
    run "touch #{deploy_to}/current/tmp/restart.txt" 
  end

  desc "Do nothing on startup so we don't get a script/spin error."
  task :start do
    puts "You may need to restart Apache."
  end

  task :stop do
    puts "You may need to stop Apache."
  end
  
  desc "Symlink extra configs and folders."
  task :symlink_extras do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/app_config.yml #{release_path}/config/app_config.yml"
    run "ln -nfs #{shared_path}/config/mongrel_cluster.yml #{release_path}/config/mongrel_cluster.yml"
    run "ln -nfs #{shared_path}/config/production.sphinx.conf #{release_path}/config/production.sphinx.conf"
    run "ln -nfs #{shared_path}/assets #{release_path}/public/assets"
    run "ln -nfs #{shared_path}/db/sphinx #{release_path}/db/sphinx"
  end

  desc "Setup shared directory."
  task :setup_shared do
    run "mkdir #{shared_path}/assets"
    run "mkdir #{shared_path}/config"
    run "mkdir #{shared_path}/db"
    run "mkdir #{shared_path}/db/sphinx"
    put File.read("config/examples/database.yml"), "#{shared_path}/config/database.yml"
    put File.read("config/examples/mongrel_cluster.yml"), "#{shared_path}/config/mongrel_cluster.yml"
    put File.read("config/examples/app_config.yml"), "#{shared_path}/config/app_config.yml"
    put File.read("config/examples/production.sphinx.conf"), "#{shared_path}/config/production.sphinx.conf"
    puts "Now edit the config files and fill assets folder in #{shared_path}."
  end
  
  desc "Sync the public/assets directory."
  task :assets do
    system "rsync -vr --exclude='.DS_Store' public/assets #{user}@#{application}:/srv/www/railscasts.com/shared/"
  end
end

after "deploy", "deploy:cleanup" # keeps only last 5 releases
after "deploy:setup", "deploy:setup_shared"
after "deploy:update_code", "deploy:symlink_extras"
