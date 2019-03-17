class SurveysController < ApplicationController

  before_action :authenticate_account!
  before_action :scope_project
  before_action :scope_issue
  before_action :enforce_permissions

  def new
    @survey = Survey.new
  end

  def create
    @survey = Survey.new(
      survey_params.merge(
        project_id: @project.id,
        issue_id: @issue.id,
        account_id: current_account.id
      )
    )
    if @survey.save
      flash[:info] = "Thank you for completing the survey."
      redirect_to project_issue_path(@project, @issue)
    else
      flash[:error] = @survey.errors.full_messages
      render :new
    end
  end

  private

  def enforce_permissions
    render_forbidden && return unless current_account.can_complete_survey_on_issue?(@issue, @project)
  end

  def scope_issue
    @issue = Issue.find(params[:issue_id])
  end

  def scope_project
    @project = Project.find_by(slug: params[:project_slug])
  end

  def survey_params
    params.require(:survey).permit(
      :project_id,
      :issue_id,
      :responsiveness,
      :sensitivity,
      :fairness,
      :community,
      :would_recommend,
      :recommendation_note
    )
  end

end
