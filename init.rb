require 'redmine'

Redmine::Plugin.register :redmine_gitbranchdisplay do
  name 'Redmine Git Branch Display'
  author 'Dominic Bou-Samra - Mincom'
  author_url 'https://github.com/dbousamra/'
  description 'A plugin adding a view of branches a revision is contained on, and the closest tag'
  version '0.0.1'

  settings :default => { :git_branches_threshold => 3 }, :partial => 'settings/gitbranchdisplay_settings'
  # This plugin adds a project module
  # It can be enabled/disabled at project level (Project settings -> Modules)
  project_module :gitbranchdisplay do
    permission :view_gitbranchdisplay, :gitbranchdisplay => :index
  end
end
