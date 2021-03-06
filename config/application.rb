require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)



module Nasi
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.autoload_paths += %W(#{config.root}/lib)
    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Copenhagen'
    config.assets.initialize_on_precompile = false
    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    config.active_job.queue_adapter = :sidekiq

    if Rails.env.development?
      config.before_configuration do
        env_file = File.join(Rails.root, 'config', 'amazon_config.yml')
        x = YAML.load(File.open(env_file))
        x.each do |key, value|
          ENV[key.to_s] = value
        end if File.exists?(env_file)

        omni_file = File.join(Rails.root, 'config', 'omniauth.yml')
        omni = YAML.load(File.open(omni_file))
        omni.each do |key, value|
          ENV[key.to_s] = value.to_s
        end if File.exists?(omni_file)
      end
    end

    PayPal::SDK.load('config/paypal.yml',  ENV['RACK_ENV'] || 'development')
    #   if Rails.env.development?
    #   config.before_configuration do
    #     env_file = File.join(Rails.root, 'config', 'amazon_config.yml')
    #    KEYS = YAML.load(File.open(env_file))
    #   end
    # end

    # AMAZON_KEYS = YAML.load_file("#{RAILS_ROOT}/config/amazon_key_config.yml")
    # Using font-awesome
    config.assets.paths << Rails.root.join("app", "assets", "fonts")

    config.generators do |g|
      g.test_framework :rspec,
        :fixtures => true,
        :view_specs => false,
        :helper_specs => false,
        :routing_specs => false,
        :controller_specs => true,
        :request_specs => true
      g.fixture_replacement :factory_girl, :dir => "spec/factories"
    end
  end
end
