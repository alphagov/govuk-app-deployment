namespace :govuk_admin_template do
  task :configure do
    case ENV["ORGANISATION"]
    when "production"
      environment_style = "production"
      environment_label = "Production"
    when "staging"
      environment_style = "preview"
      environment_label = "Staging"
    when "integration"
      # FIXME: Once the govuk_admin_template supports an 'integration' style,
      # and most/all apps have been upgraded the style should be changed here.
      environment_style = "preview"
      environment_label = "Integration"
    when "test"
      environment_style = "test"
      environment_label = "Test"
    end

    template = ERB.new <<~EOT
      GovukAdminTemplate.environment_style = '<%= environment_style %>'
      GovukAdminTemplate.environment_label = '<%= environment_label %>'
    EOT

    file_contents = template.result(binding)
    top.put(file_contents, File.join(release_path, "config", "initializers", "govuk_admin_template_environment_indicators.rb"))
  end
end

after "deploy:finalize_update", "govuk_admin_template:configure"
