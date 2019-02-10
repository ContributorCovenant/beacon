class DirectoryController < ApplicationController

  def index
    @projects = Project.directory
  end

  def show
    redirect_to directory_path unless @project = Project.public.find_by(slug: params[:slug])
    @issue_severity_levels = @project.issue_severity_levels
  end
end
