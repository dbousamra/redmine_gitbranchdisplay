module IssueChangesetHelperPatch
  def self.included(base)
    base.send(:include, InstanceMethods)
  end
 
  module InstanceMethods
    
    def assert_repo_exists(repo)
      repository = @project.repository
      if repository.nil?
         flash.now[:error] = l(:project_no_repository, :name => @project.to_s)
         render_404
         return
      end
    end

    def threshold_level
    	threshold = Setting.plugin_redmine_gitbranchdisplay[:git_branches_threshold].to_i
    end

    def branches(repo, changeset)
      branches = `#{git_command(repo)} branch -r --contains #{changeset.revision}`
      branches.strip().split('  ').each { |x| x.chomp! }
    end

    def tags(repo, changeset)
      tags = `#{git_command(repo)} describe #{changeset.revision}`
      tags.strip().split('  ').each { |x| x.chomp! }
    end

    private
    
    def git_command(repository)
      "git --git-dir #{repository.url}"
    end

  end    
end