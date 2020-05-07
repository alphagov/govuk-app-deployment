# Deploy nodejs applications using node and npm.
#
# In order for this to work for your node application, you will need to
# specify your dependencies in a packages.json at the root of your repository.

set :shared_children, shared_children + %w[log]

namespace :deploy do
  task :start do; end
  task :stop do; end

  task :restart, :roles => :app, :max_hosts => 1, :except => { :no_release => true } do
    run "sudo initctl start #{application} 2>/dev/null || sudo initctl restart #{application}"
  end

  task :install_deps, :roles => :app do
    run "cd #{release_path} && /usr/bin/npm install"
  end

  # run post deploy hook inside the release directory with the correct environment
  task :run_post_deploy_hook, :roles => :app do
    run <<~EOS
      if [ -f '#{release_path}/hooks/post_deploy' ]; then
        cd #{release_path} && govuk_setenv #{application} hooks/post_deploy;
      fi
    EOS
  end

  task :link_shared_children, :roles => :app do
    commands = []
    shared_children.each do |dir|
      d = dir.shellescape
      if dir.rindex("/")
        commands += ["rm -rf -- #{release_path}/#{d}",
                     "mkdir -p -- #{release_path}/#{dir.slice(0...(dir.rindex('/'))).shellescape}"]
        # When symlinking we need to be sure this doesn't have a
        # trailing slash
        dir = dir.slice(0...(dir.rindex("/")))
        d = dir.shellescape
      else
        commands << "rm -rf -- #{release_path}/#{d}"
      end
      commands << "ln -s -- #{shared_path}/#{dir.split('/').last.shellescape} #{release_path}/#{d}"
    end

    run commands.join(" && ") if commands.any?
  end

  task :upload_organisation_config do
    Dir.glob(File.join(Dir.pwd, "to_upload/#{ENV['ORGANISATION']}/*")).each do |f|
      top.upload(f, File.join(release_path, File.basename(f)))
    end
  end
end

before "deploy:finalize_update", "deploy:install_deps"
after "deploy:finalize_update", "deploy:upload_organisation_config"
after "deploy:finalize_update", "deploy:link_shared_children"
before "deploy:restart", "deploy:run_post_deploy_hook"
after "deploy:notify", "deploy:notify:github", "deploy:notify:docker"
