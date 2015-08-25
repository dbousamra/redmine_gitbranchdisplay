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

    # Need to add following line to git.rb
    # h["heads_hash"] = Digest::MD5.hexdigest(repo_heads.sort.join('|'))
    def branches(repo, changeset)
#      branches = `#{git_command(repo)} branch --contains #{changeset.revision}`
#      branches.strip().split(/[* ] /).each { |x| x.chomp! }
      heads_hash = (repo.extra_info || {})['heads_hash']
      if heads_hash.nil?
        heads_hash = Digest::MD5.hexdigest(repo.heads_from_branches_hash.sort.join('|'))
        repo.merge_extra_info({'heads_hash' => heads_hash})
        repo.save!
      end
      begin
         branch_data = changeset.branches ? JSON.parse(changeset.branches) : nil
      rescue
         branch_data = nil
      end
      if branch_data.nil? or branch_data['heads_hash'] != heads_hash
        branches = `#{git_command(repo)} branch --contains #{changeset.revision}`
        branches = branches.strip().split(/[* ] /).each { |x| x.chomp! }.sort
        branch_data = {'branches' => branches, 'heads_hash' => heads_hash}
        changeset.branches = branch_data.to_json
        changeset.save!
      end
      branch_data['branches']
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
