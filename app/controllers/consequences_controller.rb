class ConsequencesController < ApplicationController

  before_action :authenticate_account!
  before_action :scope_guide
  before_action :enforce_permissions

  def create
    @guide.consequences.create!(consequence_params)
    if organization = @guide.organization
      redirect_to organization_consequence_guide_path(organization, @guide)
    else
      redirect_to project_consequence_guide_path(@guide.project, @guide)
    end
  end

  def update
    consequence = @guide.consequences.find(params[:id])
    if params[:commit] == "Delete"
      consequence.destroy
    else
      consequence.update_attributes(consequence_params)
    end
    if organization = @guide.organization
      redirect_to organization_consequence_guide_path(organization, @guide)
    else
      redirect_to project_consequence_guide_path(@guide.project, @guide)
    end
  end

  def destroy
    @guide.consequences.find(:id).destroy
    if organization = @guide.organization
      redirect_to organization_consequence_guide_path(organization, @guide)
    else
      redirect_to project_consequence_guide_path(@guide.project, @guide)
    end
  end

  private

  def consequence_params
    params.require(:consequence).permit(
      :level,
      :severity,
      :label,
      :action,
      :consequence
    )
  end

  def enforce_permissions
    if organization = @guide.organization
      render_forbidden && return unless current_account.can_manage_organization_consequence_guide?(organization)
    else
      render_forbidden && return unless current_account.can_manage_project_consequence_guide?(@guide.project)
    end
  end

  def scope_guide
    @guide = ConsequenceGuide.find(params[:consequence_guide_id])
  end

end
