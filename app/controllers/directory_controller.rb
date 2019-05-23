class DirectoryController < ApplicationController

  def index
    @projects = Project.for_directory.starting_with(@current_index)
  end

  def show
    if @project = Project.for_directory.find_by(slug: params[:slug])
      breadcrumb @project.name, directory_project_path(@project)
      @consequences = @project.consequence_guide_from_org_or_project.consequences
      @report = TransparencyReportingService.new(@project)
    else
      ActivityLoggingService.log(current_account, :four_o_fours) if current_account
      redirect_to root_path
    end
  end

  def search
    if params[:q].present?
      @projects = Project.for_directory.where("name ILIKE ? OR organization_name ILIKE ?", "#{params[:q]}%", "#{params[:q]}%")
    else
      @projects = []
    end
    render :index
  end

end
