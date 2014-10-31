require 'git'

module BoshSyncer
  module ReleaseManager
    def release_manager
       BoshSyncer::ReleaseManager::ReleaseManager.new
    end

    class ReleaseManager
      def fetch(repo, options = {branch: 'master'})
        temp_folder = nil
        current_folder = FileUtils.pwd

        release_folder = if url?(repo)
          temp_folder = Dir.mktmpdir('release')
          Git.clone(repo, 'release', path: temp_folder, branch: options[:branch])
          temp_folder
        else
          repo
        end

        FileUtils.chdir(release_folder)

        yield(release_folder)

        FileUtils.chdir(current_folder)
        FileUtils.rm(temp_folder) if temp_folder
      end

      def url?(repo)
        repo =~ git_url_regexp
      end

      def git_url_regexp
        /^((git|ssh|http(s)?)|(git@[\w.]+))(:\/\/)?([\w\.@\:\/\-\~]+)(.git)(\/)?/
      end
    end
  end
end
