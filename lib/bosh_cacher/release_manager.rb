require 'git'

module BoshCacher
  module ReleaseManager
    def release_manager
       BoshCacher::ReleaseManager::ReleaseManager.new
    end

    class ReleaseManager
      def fetch(repo, options = {branch: 'master'}, &block)
        temp_folder = nil
        current_folder = FileUtils.pwd

        release_folder = if url?(repo)
          temp_folder = Dir.mktmpdir('release')
          Git.clone(repo, 'release', path: temp_folder, branch: options[:branch])
          temp_folder
        else
          repo
        end
        
        yield(release_folder)

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
