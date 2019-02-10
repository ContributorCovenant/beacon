class DirectoryController < ApplicationController

  def index
    @projects = Project.for_directory
  end

  def show
    if @project = Project.for_directory.find_by(slug: params[:slug])
      @issue_severity_levels = @project.issue_severity_levels
    else
      redirect_to directory_path
    end
  end
end
