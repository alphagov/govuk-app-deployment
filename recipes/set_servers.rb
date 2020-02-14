require 'set'

namespace :deploy do
  # deploy:set_servers
  #
  # This uses the 'server_class' cap parameter, if set, to determine the
  # deploy destination. It makes a hard assumption that the deployment is
  # running in the same environment as the deployment destination, and so is
  # unlikely to be useful when not deploying from a Jenkins server.
  #
  task :set_servers do
    # Will raise if server_class isn't set
    cls = fetch(:server_class, false)

    unless cls
      logger.info "set_servers: 'server_class' not set, so not setting up roles"
      next
    end

    DEFAULT_CONFIG = { roles: %i[web app db] }.freeze

    classes = if cls.respond_to? :join
                # Array of strings or symbols, e.g
                # set: :server_class, ['frontend', 'backend']
                Hash[cls.zip([DEFAULT_CONFIG] * cls.size)]
              elsif cls.is_a?(Symbol) || cls.is_a?(String)
                # Standard case of single symbol or string, e.g
                # set :server_class, 'backend'
                Hash[cls, DEFAULT_CONFIG]
              else
                # Hash style with specifically defined roles, e.g
                # {frontend: {roles: [:db, :app]}}
                cls
              end

    roles[:app].clear
    roles[:web].clear
    roles[:db].clear

    classes.each_pair do |c, extra|
      # Get list of machines in the node class from Puppetmaster, using the
      # govuk_node_list command.
      begin
        nodes = %x{govuk_node_list -c "#{c}"}.split
        if nodes.empty?
          raise CommandError.new("set_servers: no servers with class '#{c}' in this environment!")
        end
      rescue Errno::ENOENT
        raise CommandError.new("set_servers: govuk_node_list is not available!")
      end

      nodes.each_with_index do |node, index|
        is_draft_server = !!(c =~ /^draft/)
        parent.server node, *extra[:roles], :server_class => c, :primary => index.zero?, :draft => is_draft_server
      end

      nodes_to_deploy = find_servers(:only => { :server_class => c }).map do |server|
        opts = server.options[:primary] ? " (primary)" : ""
        "#{server.host}#{opts}"
      end

      logger.info "set_servers: deploying to #{c} => #{nodes_to_deploy.join(', ')}"
    end
  end
end

on :start, "deploy:set_servers"
