class DirectoryController < ApplicationController

  def index
    @page_index = Project.for_directory.pluck(:name).map(&:first).uniq
    return unless @current_index = params[:page] || @page_index.first
    @previous_index = @page_index[@page_index.index(@current_index) - 1]
    @next_index = @page_index[@page_index.index(@current_index) - 1]
    @projects = Project.for_directory.starting_with(@current_index)
  end

  def show
    if @project = Project.for_directory.find_by(slug: params[:slug])
      @consequences = @project.consequence_guide_from_org_or_project.consequences
      @report = TransparencyReportingService.new(@project)
    else
      redirect_to directory_path
    end
  end
end
