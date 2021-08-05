# Deploy python3 applications using pip and virtualenv.
#
# In order for this to work for your python application, you will need to
# specify your dependencies either in a setuptools-compatible "setup.py" or in a
# "requirements.txt" at the root of your repository. For the sake of simplicity,
# the latter is usually desirable.

set :virtualenv_name, fetch(:virtualenv_name, "venv3")
set :shared_children, shared_children + [virtualenv_name]
set :virtualenv_python_binary, fetch(:virtualenv_python_binary, "python3.6")
set(:virtualenv_path) { "#{shared_path}/#{virtualenv_name}" }
set :sleep_after_server_start, 1

namespace :deploy do
  task :start do; end
  task :stop do; end

  task :restart, :roles => :app, :max_hosts => 1, :except => { :no_release => true } do
    if fetch(:perform_hard_restart, false)
      # hard-restart is a non-graceful restart of the app.  This has the advantage
      # of being immediate, and blocking.  Used by some of the post data-syncing
      # scripts
      run "sudo initctl start #{application} 2>/dev/null || sudo initctl restart #{application}"
    else
      run "sudo initctl start #{application} 2>/dev/null || sudo initctl reload #{application}"
    end
  end

  desc "A non-graceful restart of the app. Useful for changing Python version"
  task :hard_restart do
    set(:perform_hard_restart, true)
    restart
  end

  task :create_virtualenv, :roles => :app do
    run "python3.6 -m venv '#{virtualenv_path}'"
  end

  task :install_deps, :roles => :app do
    run "if [ -f '#{release_path}/setup.py' ]; then echo '-e .' >> '#{release_path}/requirements.txt'; fi"
    run "'#{virtualenv_path}/bin/pip' install --download-cache '#{shared_path}/download-cache' --exists-action=w -r '#{release_path}/requirements.txt'"
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

  task :crontab, :roles => :app do
    fetch(:cronjobs, {}).each do |name, cronjob|
      job = "#{cronjob.join(' ')} >> #{release_path}/log/cron.out.log 2>> #{release_path}/log/cron.err.log"
      # Replace cronjob with #{name} with #{job}
      run "crontab -l | grep -v '# #{name}$' | ruby -e 'puts \"\#{ARGF.read}#{job} \# #{name}\"' | crontab -"
    end
  end

  task :upgrade_pip do
    run "cd #{release_path} && #{virtualenv_path}/bin/pip install --upgrade pip==21.2.2"
  end
end

after "deploy:setup", "deploy:create_virtualenv"
before "deploy:finalize_update", "deploy:upgrade_pip", "deploy:install_deps"
after "deploy:finalize_update", "deploy:link_shared_children"
before "deploy:restart", "deploy:run_post_deploy_hook"
before "deploy:restart", "deploy:crontab"
after "deploy:notify", "deploy:notify:github", "deploy:notify:docker"
