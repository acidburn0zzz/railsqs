require 'rails/generators'
require 'rails/generators/rails/app/app_generator'

module Railsqs
  class AppGenerator < Rails::Generators::AppGenerator
    class_option :database, :type => :string, :aliases => '-d', :default => 'postgresql',
      :desc => "Preconfigure for selected database (options: #{DATABASES.join('/')})"

    class_option :github, :type => :string, :aliases => '-G', :default => nil,
      :desc => 'Create Github repository and add remote origin pointed to repo'

    def finish_template
      invoke :railsqs_customization
      super
    end

    def railsqs_customization
      invoke :customize_gemfile
      invoke :setup_development_environment
      invoke :setup_test_environment
      invoke :setup_production_environment
      invoke :setup_staging_environment
      invoke :setup_secret_token
      invoke :create_railsqs_views
      invoke :setup_coffeescript
      invoke :configure_app
      invoke :setup_stylesheets
      invoke :install_bitters
      invoke :copy_miscellaneous_files
      invoke :customize_error_pages
      invoke :remove_routes_comment_lines
      invoke :setup_homepage
      invoke :setup_git
      invoke :setup_database
      invoke :outro
    end

    def customize_gemfile
      build :replace_gemfile
      build :set_ruby_to_version_being_used
      bundle_command 'install'
    end

    def setup_database
      say 'Setting up database'

      if 'postgresql' == options[:database]
        build :use_postgres_config_template
      end

      build :create_database
    end

    def setup_development_environment
      say 'Setting up the development environment'
      build :raise_on_delivery_errors
      build :raise_on_unpermitted_parameters
      build :provide_setup_script
      build :provide_dev_prime_task
      build :configure_generators
      build :configure_i18n_for_missing_translations
    end

    def setup_test_environment
      say 'Setting up the test environment'
      build :enable_database_cleaner
    end

    def setup_production_environment
      say 'Setting up the production environment'
      build :configure_newrelic
      build :configure_smtp
      build :enable_rack_deflater
    end

    def setup_staging_environment
      say 'Setting up the staging environment'
      build :setup_staging_environment
    end

    def setup_secret_token
      say 'Moving secret token out of version control'
      build :setup_secret_token
    end

    def create_railsqs_views
      say 'Creating railsqs views'
      build :create_partials_directory
      build :create_shared_flashes
      build :create_shared_javascripts
      build :create_shared_nav
      build :create_shared_footer
      build :create_application_layout
    end

    def setup_coffeescript
      say 'Setting up CoffeeScript defaults'
      build :remove_turbolinks
    end

    def configure_app
      say 'Configuring app'
      build :configure_action_mailer
      build :configure_time_zone
      build :configure_time_formats
      build :configure_rack_timeout
      build :disable_xml_params
      build :fix_i18n_deprecation_warning
      build :setup_default_rake_task
      build :setup_puma
      build :setup_foreman
    end

    def setup_stylesheets
      say 'Set up stylesheets'
      build :setup_stylesheets
    end

    def install_bitters
      say 'Install Bitters'
      build :install_bitters
    end

    def setup_homepage
      build :setup_homepage      
    end

    def setup_git
      if !options[:skip_git]
        say 'Initializing git'
        invoke :setup_gitignore
        invoke :init_git
      end
    end

    def setup_gitignore
      build :gitignore_files
    end

    def init_git
      build :init_git
    end

    def copy_miscellaneous_files
      say 'Copying miscellaneous support files'
      build :copy_miscellaneous_files
    end

    def customize_error_pages
      say 'Customizing the 500/404/422 pages'
      build :customize_error_pages
    end

    def remove_routes_comment_lines
      build :remove_routes_comment_lines
    end

    def outro
      build :run_initial_setup
      say 'Congratulations! You just pulled our railsqs.'      
    end

    def run_bundle
      # Let's not: We'll bundle manually at the right spot
    end

    protected

    def get_builder_class
      Railsqs::AppBuilder
    end

    def using_active_record?
      !options[:skip_active_record]
    end
  end
end
