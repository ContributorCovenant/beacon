class ProjectsController < ApplicationController

  def index
    @projects = Project.all.order(:name)
  end

  def new
    @project = Project.new(name: "My Project")
  end

  def create
    @project = Project.new(project_params)
    if @project.save
      redirect_to @project
    else
     flash[:error] = @project.errors.full_messages
     render :new
    end
  end

  def show
    @project = Project.find_by(slug: params[:slug])
  end

  private

  def project_params
    params.require(:project).permit(:name, :url, :coc_url, :description)
  end

end
