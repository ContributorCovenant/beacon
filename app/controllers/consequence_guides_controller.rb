class ConsequenceGuidesController < ApplicationController

  before_action :authenticate_account!
  before_action :scope_organization
  before_action :scope_project
  before_action :scope_guide
  before_action :enforce_permissions, only: [:clone]

  def show
    @consequences = @guide.consequences
    @available_guides = ["beacon_default"]
    if @project
      @available_guides << ["organization_default", @organization.projects.map(&:name)] if @organization
      @available_guides << current_account.projects.map(&:name)
    end
    @available_guides.flatten!
    @severities = (1..10).to_a - @consequences.map(&:severity)

    @subject = @organization || @project
  end

  def clone
    clone_from(guide_params[:default_source])
    if @organization
      redirect_to organization_consequence_guide_path(@organization, @guide) and return
    elsif @project
      redirect_to project_consequence_guide_path(@project, @guide) and return
    end
  end

  private

  def clone_from(source)
    if source == "Beacon Default"
      @guide.clone_from(ConsequenceGuide.find_by(scope: "template"))
    elsif source == "Organization Default"
      @guide.clone_from(ConsequenceGuide.find_by(organization_id: project.organization_id))
    else
      if project = current_account.projects.find{ |project| project.name == source }
        @guide.clone_from(project.consequence_guide)
      else
        render_forbidden && return
      end
    end
  end

  def enforce_permissions
    if @organization
      render_forbidden && return unless current_account.can_manage_organization_consequence_guide?(@organization)
    else
      render_forbidden && return unless current_account.can_manage_project_consequence_guide?(@project)
    end
  end

  def guide_params
    params.require(:consequence_guide).permit(:default_source)
  end

  def scope_organization
    @organization = Organization.find_by(slug: params[:organization_slug])
  end

  def scope_project
    @project = Project.find_by(slug: params[:project_slug])
  end

  def scope_guide
    @guide = ConsequenceGuide.find_by(id: params[:id])
    @guide ||= ConsequenceGuide.find_by(id: params[:consequence_guide_id])
  end

end
