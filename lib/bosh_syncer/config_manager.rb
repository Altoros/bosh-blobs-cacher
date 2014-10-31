module BoshSyncer
  module ConfigManager
    def config_manager()
       BoshSyncer::ReleaseManager::ReleaseManager.new
    end

    class ReleaseManager
      def setup(config_path, target_release = FileUtils.pwd)
        target_config_path = File.join(target_release, 'config', 'private.yml')
        old_target_config_path = target_config_path + '.old'
        FileUtils.mv(target_config_path, old_target_config_path) if File.exist?(target_config_path)
        FileUtils.cp(config_path, target_config_path)

        yield

        if File.exist?(old_target_config_path)
          FileUtils.mv(old_target_config_path, target_config_path)
        else 
          FileUtils.rm(target_config_path)
        end
      end
    end
  end
end
