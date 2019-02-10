class DirectoryController < ApplicationController

  def index
    @projects = Project.for_directory
  end

  def show
    redirect_to directory_path unless @project = Project.for_directory.find_by(slug: params[:slug])
    @issue_severity_levels = @project.issue_severity_levels
  end
end
