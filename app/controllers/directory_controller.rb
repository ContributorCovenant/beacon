class DirectoryController < ApplicationController

  breadcrumb "Directory", :directory_path

  def index
    @page_index = Project.for_directory.pluck(:sort_key).uniq
    return unless @current_index = params[:page] || @page_index.first
    @previous_index = @page_index[@page_index.index(@current_index) - 1]
    @next_index = @page_index[@page_index.index(@current_index) - 1]
    @projects = Project.for_directory.starting_with(@current_index)
  end

  def show
    if @project = Project.for_directory.find_by(slug: params[:slug])
      breadcrumb @project.name, directory_project_path(@project)
      @consequences = @project.consequence_guide_from_org_or_project.consequences
      @report = TransparencyReportingService.new(@project)
    else
      ActivityLoggingService.log(current_account, :four_o_fours) if current_account
      redirect_to directory_path
    end
  end

  def search
    @page_index = Project.for_directory.pluck(:sort_key).uniq
    if params[:q].present?
      @projects = Project.for_directory.where("name ILIKE ? OR organization_name ILIKE ?", "#{params[:q]}%", "#{params[:q]}%")
    else
      @projects = []
    end
    render :index
  end

end
