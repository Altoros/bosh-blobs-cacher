require 'erb'
require 'yaml'
require 'ostruct'
# require 'bosh/template/evaluation_context'

module BoshCacher
  class ConfigRenderer
    attr_reader :options

    def initialize(options = {})
      @options = {validate: true}.merge(options)
      load_from_file
      load_from_environment
      validate! if options[:validate]
    end

    def render_final(target)
      File.write(target, render('final'))
    end

    def render_private(target)
      File.write(target, render('private'))
    end

    def render_example_config(path)
      hash = required_fields.inject({}) { |r, s| r.merge!(s => "<#{s}>") }
      hash['provider'] = provider.to_s
      File.write(path, {'cacher' => hash}.to_yaml)
    end

  private

    def load_from_file
      path = options[:config]
      config.merge!(Bosh::Common.symbolize_keys(YAML.load_file(path)['cacher'])) if path && File.exist?(path)
    end

    def load_from_environment
      environment_options = required_fields.inject({}) do |r, s|
        r.merge!(s => ENV["#{provider}_#{s}"])
      end
      config.merge!(Bosh::Common.symbolize_keys(environment_options))
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
      @mapping ||= {
        openstack: %w(auth_url username password tenant region container),
        hp: %w(access_key secret_key tenant zone container),
        rackspace: %w(username password region container),
        s3: %w(bucket access_key_id secret_access_key),
        local: %w(path)
      }
    end

    def provider
      if @provider.nil?
        @provider = config[:provider] || ENV['provider']
        if @provider.nil?
          warning("provider is not specified. Going to use Openstack.")
          @provider = 'openstack'
        end
      end
      @provider.to_sym
    end
 
    def config
      @config ||= {}
    end

    def render(template_name)
      @context ||= OpenStruct.new(config)
      erb = ERB.new(load_template(provider, template_name))
      erb.result(@context.instance_eval { binding })
    end

    def load_template(provider, template_name)
      template = File.expand_path("../../../templates/#{provider}/#{template_name}.yml.erb", __FILE__)
      File.read(template)
    end

  end
end
