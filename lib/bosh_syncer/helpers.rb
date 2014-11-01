module BoshSyncer
  module Helpers

    def set_folder(folder)
      Dir.chdir(folder)
      update_config
    end

    def update_config
      @work_dir = folder
      @release = nil
    end

  end
end
