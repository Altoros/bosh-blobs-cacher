module BoshSyncer
  class ConfigRenderer
    attr_reader :options

    def initialize(options)
      @options = options
      load_from_file
      load_from_environment
      validate!
    end

    def render_final(target)
    end

    def render_private(target)
    end

  private

    def load_from_file
      path = options[:config]
      config.merge!(YAML.load_file(path)) if path && File.exist?(path)
    end

    def load_from_environment
      environment_options = required_fields.inject({}) do |r, s|
        r.merge!(s => ENV["#{provider}_#{s}"])
      end
      config.merge!(environment_options)
    end

    def validate!
      missing_keys = required_fields - config.heys
      unless missing_keys.empty?
        err("#{missing_keys.join(', ')} keys are missing for #{provider} provider.")
      end
    end

    def required_fields
      @required_fields ||= mappings[provider]
    end

    # https://github.com/cloudfoundry/bosh/blob/master/bosh_cli/lib/cli/release.rb#L69-L75
    def mappings
      @mapping = {
        openstack: %w(auth_url username password tenant region container),
        hp: %w(access_key secret_key tenant zone container),
        rackspace: %w(username password region container),
        s3: %w(bucket access_key_id secret_access_key),
        local: %w(path)
      }
    end

    def provider
      @provider ||= options[:provider] || config[:provider] || ENV['PROVIDER']
          (warning("Provider is not specified. Going to use Openstack.") && 
           'openstack')
    end
 
    def config
      @config ||= {}
    end
  end  
end