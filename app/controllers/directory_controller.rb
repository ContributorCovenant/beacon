class DirectoryController < ApplicationController
  def index
    @projects = Project.includes(:project_setting).all.order(:name).select(&:public?)
  end

  def show
    @project = Project.find_by(slug: params[:slug])
    @issue_severity_levels = @project.issue_severity_levels
    redirect_to :index unless @project.public?
  end
end
