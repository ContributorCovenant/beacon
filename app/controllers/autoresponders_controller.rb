class AutorespondersController < ApplicationController

  before_action :authenticate_account!
  before_action :scope_organization
  before_action :scope_project
  before_action :enforce_permissions
  before_action :scope_autoresponder, only: [:edit, :show, :update]
  before_action :scope_available_sources, only: [:new, :edit]

  def new
    if @project
      @autoresponder = Autoresponder.new(project_id: @project.id)
      org_autoresponder = @project.organization.present? ? "Organization Default" : nil
    else
      @autoresponder = Autoresponder.new(organization_id: @organization.id)
    end
    @available_sources = ["Beacon Default", org_autoresponder, @available_sources].flatten.compact - [@project&.name]
  end

  def show
  end

  def create
    if @project
      @template = Autoresponder.new(respondent_template_params.merge(project_id: @project.id))
    elsif @organization
      @template = Autoresponder.new(respondent_template_params.merge(organization_id: @organization.id))
    end
    if @template.save
      redirect_to project_path(@project) if @project
      redirect_to organization_path(@organization) if @organization
    else
      flash[:error] = @template.errors.full_messages
      render :new
    end
  end

  def clone
    if existing = @subject.respondent_template
      existing.destroy
    end
    source = respondent_template_params[:respondent_template_default_source]
    if source == "Beacon Default"
      @template = @subject.create_respondent_template(text: RespondentTemplate.beacon_default.text)
    elsif source == "Organization Default"
      @template = @subject.create_respondent_template(text: @organization&.respondent_template&.text || @project.organization.respondent_template.text)
    else
      source = current_account.projects.find_by(name: source).respondent_template
      @template = @subject.create_respondent_template(text: source.text)
    end
    flash[:notice] = "You have successfully updated the respondent template."
    render :edit
  end

  def edit
  end

  def update
    if @autoresponder.update_attributes(autoresponder_params)
      redirect_to @subject
    else
      flash[:error] = @autoresponder.errors.full_messages
    end
  end

  private

  def enforce_permissions
    render_forbidden && return if @project && !current_account.can_manage_project_autoresponder?(@project)
    render_forbidden && return if @organization && !current_account.can_manage_organization_autoresponder?(@organization)
  end

  def autoresponder_params
    params.require(:autoresponder).permit(:text)
  end

  def scope_autoresponder
    @autoresponder = @subject.autoresponder
  end

  def scope_available_sources
    if @project&.organization
      projects_with_autoresponder = @project.organization.projects.select(&:autoresponder?)
    elsif @organization
      projects_with_autoresponder = @organization.projects.select(&:autoresponder?)
    end
    projects_with_autoresponder ||= current_account.personal_projects.select(&:autoresponder?)
    @available_sources = projects_with_autoresponder.map(&:name).flatten
  end

  def scope_organization
    @organization = Organization.find_by(slug: params[:organization_slug])
    @subject = @organization
  end

  def scope_project
    @project = Project.find_by(slug: params[:project_slug])
    @subject = @project
  end

end
