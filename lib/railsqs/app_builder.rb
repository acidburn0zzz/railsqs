module Railsqs
  class AppBuilder < Rails::AppBuilder
    include Railsqs::Actions

    def readme
      template 'README.md.erb', 'README.md'
    end

    def raise_on_delivery_errors
      replace_in_file 'config/environments/development.rb',
        'raise_delivery_errors = false', 'raise_delivery_errors = true'
    end

    def raise_on_unpermitted_parameters
      config = <<-RUBY
    config.action_controller.action_on_unpermitted_parameters = :raise
      RUBY

      inject_into_class "config/application.rb", "Application", config
    end

    def provide_setup_script
      template 'bin_setup.erb', 'bin/setup', port_number: port_number, force: true
      run 'chmod a+x bin/setup'
    end

    def provide_dev_prime_task
      copy_file 'development_seeds.rb', 'lib/tasks/development_seeds.rake'
    end

    def configure_generators
      config = <<-RUBY

    config.generators do |generate|
      generate.helper false
      generate.javascript_engine false
      generate.stylesheets false
    end

      RUBY

      inject_into_class 'config/application.rb', 'Application', config
    end

    def configure_smtp
      copy_file 'smtp.rb', 'config/smtp.rb'

      prepend_file 'config/environments/production.rb',
        %{require Rails.root.join("config/smtp")\n}

      config = <<-RUBY

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = SMTP_SETTINGS
      RUBY

      inject_into_file 'config/environments/production.rb', config,
        :after => 'config.action_mailer.raise_delivery_errors = false'
    end

    def enable_rack_deflater
      config = <<-RUBY

  # Enable deflate / gzip compression of controller-generated responses
  config.middleware.use Rack::Deflater
      RUBY

      inject_into_file 'config/environments/production.rb', config,
        :after => "config.serve_static_assets = false\n"
    end


    def setup_staging_environment
      staging_file = 'config/environments/staging.rb'
      copy_file 'staging.rb', staging_file

      config = <<-RUBY

Rails.application.configure do
  # ...
end
      RUBY

      append_file staging_file, config
    end

    def setup_secret_token
      template 'secrets.yml', 'config/secrets.yml', force: true
    end

    def create_partials_directory
      empty_directory 'app/views/application'
    end

    def create_shared_nav
      copy_file '_navigation.html.erb', 'app/views/application/_navigation.html.erb'
    end

    def create_shared_footer
      copy_file '_footer.html.erb', 'app/views/application/_footer.html.erb'
    end

    def create_shared_flashes
      copy_file '_flashes.html.erb', 'app/views/application/_flashes.html.erb'
    end

    def create_shared_javascripts
      copy_file '_javascript.html.erb', 'app/views/application/_javascript.html.erb'
    end

    def create_application_layout
      template 'railsqs_layout.html.erb.erb',
        'app/views/layouts/application.html.erb',
        force: true
    end

    def remove_turbolinks
      replace_in_file 'app/assets/javascripts/application.js',
        /\/\/= require turbolinks\n/,
        ''
      inject_into_file 'app/assets/javascripts/application.js',
        "//= require bootstrap-sprockets\n", after: "jquery_ujs\n"
    end

    def use_postgres_config_template
      template 'postgresql_database.yml.erb', 'config/database.yml',
        force: true
    end

    def create_database
      bundle_command 'exec rake db:create db:migrate'
    end

    def replace_gemfile
      remove_file 'Gemfile'
      template 'Gemfile.erb', 'Gemfile'
    end

    def enable_database_cleaner

    end

    def configure_spec_support_features
      empty_directory_with_keep_file 'spec/features'
      empty_directory_with_keep_file 'spec/support/features'
    end

    def configure_minitest_spinach
      # TODO
      #remove_file "spec/rails_helper.rb"
      #remove_file "spec/spec_helper.rb"
      #copy_file "rails_helper.rb", "spec/rails_helper.rb"
      #copy_file "spec_helper.rb", "spec/spec_helper.rb"
    end


    def configure_time_zone
      config = <<-RUBY
    config.active_record.default_timezone = :utc
      RUBY

      inject_into_class 'config/application.rb', 'Application', config
    end

    def configure_time_formats
      remove_file 'config/locales/en.yml'
      copy_file 'config_locales_en.yml', 'config/locales/en.yml'
    end

    def configure_rack_timeout
      copy_file 'rack_timeout.rb', 'config/initializers/rack_timeout.rb'
    end

    def configure_action_mailer
      action_mailer_host 'development', "localhost:#{port_number}"
      action_mailer_host 'test', 'www.example.com'
      action_mailer_host 'staging', "staging.#{app_name}.com"
      action_mailer_host 'production', "#{app_name}.com"
    end

    def fix_i18n_deprecation_warning
      config = <<-RUBY
    config.i18n.enforce_available_locales = true
      RUBY

      inject_into_class 'config/application.rb', 'Application', config
    end

    def generate_spinach
      run 'mkdir -p features/support'
      copy_file 'env.rb', 'features/support/env.rb'
    end

    def setup_puma
      copy_file 'puma.rb', 'config/puma.rb'
    end
    
    def setup_foreman
      copy_file 'sample.env', '.sample.env'      
      copy_file 'Procfile', 'Procfile'
    end

    def setup_stylesheets
      remove_file 'app/assets/stylesheets/application.css'
      copy_file 'application.css.scss',
        'app/assets/stylesheets/application.css.scss'
      copy_file 'bootstrap.scss', 'app/assets/stylesheets/bootstrap.css.scss'
    end

    def install_bitters
      run "bitters install --path app/assets/stylesheets"
    end

    def gitignore_files
      remove_file '.gitignore'
      copy_file 'railsqs_gitignore', '.gitignore'
    end


    def setup_homepage
      bundle_command 'exec rails g controller Homepages show'
      replace_in_file 'config/routes.rb', "get 'homepages/show'", "root 'homepages#show'"
    end

    def setup_gurad
      copy_file 'Guardfile', 'Guardfile'
    end

    def init_git
      run 'git init'
    end


    def copy_miscellaneous_files
      copy_file 'errors.rb', 'config/initializers/errors.rb'
    end

    def customize_error_pages
      meta_tags =<<-EOS
  <meta charset="utf-8" />
  <meta name="ROBOTS" content="NOODP" />
  <meta name="viewport" content="initial-scale=1" />
      EOS

      %w(500 404 422).each do |page|
        inject_into_file "public/#{page}.html", meta_tags, :after => "<head>\n"
        replace_in_file "public/#{page}.html", /<!--.+-->\n/, ''
      end
    end

    def remove_routes_comment_lines
      replace_in_file 'config/routes.rb',
        /Rails\.application\.routes\.draw do.*end/m,
        "Rails.application.routes.draw do\nend"
    end

    def setup_default_rake_task

    end

    def run_initial_setup
      run 'bin/setup'
    end

    private

    def generate_secret
      SecureRandom.hex(64)
    end

    def port_number
      @port_number ||= [3000, 4000, 5000, 7000, 8000, 9000].sample
    end
  end
end
