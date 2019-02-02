class RespondentTemplatesController < ApplicationController

  before_action :authenticate_account!
  before_action :scope_project
  before_action :enforce_permissions

  def new
    @template = RespondentTemplate.new(project_id: @project.id, text: RespondentTemplate.beacon_default.text)
  end

  def create
    @template = RespondentTemplate.new(respondent_template_params.merge(project_id: @project.id))
    projects_with_respondent_template = current_account.projects.select{ |project| project.respondent_template? }
    @available_templates = (["Beacon Default"] << projects_with_respondent_template.map(&:name)) - [@project.name]
    if @template.save
      redirect_to project_path(@project)
    else
      flash[:error] = @template.errors.full_messages
      render :new
    end
  end

  def clone
    if existing = @project.respondent_template
      existing.destroy
    end
    source = respondent_template_params[:respondent_template_default_source]
    if source == "Beacon Default"
      @project.create_respondent_template(text: RespondentTemplate.beacon_default.text)
    else
      source = current_account.projects.find_by(name: source).respondent_template
      @project.create_respondent_template(text: source.text)
    end
    flash[:notice] = "You have successfully updated the respondent template."
    redirect_to @project
  end

  def edit
    @template = @project.respondent_template
    projects_with_respondent_template = current_account.projects.select{ |project| project.respondent_template? && project.name != @project.name }
    @available_templates = (["Beacon Default"] << projects_with_respondent_template.map(&:name)).flatten
  end

  def update
    @template = @project.respondent_template
    if @template.update_attributes(respondent_template_params)
      redirect_to project_path(@project)
    else
      flash[:error] = @template.errors.full_messages
    end
  end

  private

  def enforce_permissions
    render_forbidden && return unless current_account.can_manage_respondent_template?(@project)
  end

  def respondent_template_params
    params.require(:respondent_template).permit(:text, :respondent_template_default_source)
  end

  def scope_project
    @project = Project.find_by(slug: params[:project_slug])
  end

end
