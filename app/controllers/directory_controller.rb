class DirectoryController < ApplicationController

  def index
    # TODO: this query is going to need to be optimized before performance becomes an issue
    @projects = Project.includes(:project_setting).all.order(:name).select(&:show_in_directory?)
  end

  def show
    @project = Project.find_by(slug: params[:slug])
    @issue_severity_levels = @project.issue_severity_levels
    redirect_to :index unless @project.public?
  end
end
