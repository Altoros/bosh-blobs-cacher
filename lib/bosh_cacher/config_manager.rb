require 'yaml'
require 'bosh_cacher/config_renderer'

module BoshCacher
  module ConfigManager
    def config_manager
       BoshCacher::ConfigManager::ConfigManager.new
    end

    class ConfigManager
      def setup(options, release_folder = Dir.pwd)
        config_renderer = BoshCacher::ConfigRenderer.new(options)
        final_config_path   = File.join(release_folder, 'config', 'final.yml')
        private_config_path = File.join(release_folder, 'config', 'private.yml')
        save_files(final_config_path, private_config_path)

        config_renderer.render_final(final_config_path)
        config_renderer.render_private(private_config_path)

        yield

        restore_files(final_config_path, private_config_path)
      end

      def save_files(*args)
        args.each { |path| mv(path, "#{path}.old") }
      end

      def resrore_files(*args)
        args.each { |path| mv("#{path}.old", path) }
      end

      def mv(source, target)
        FileUtils.mv(source, target) if File.exist?(source)
      end
    end

  end
end
