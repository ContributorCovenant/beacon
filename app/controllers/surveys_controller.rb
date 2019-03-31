class SurveysController < ApplicationController

  before_action :authenticate_account!
  before_action :scope_project
  before_action :scope_issue
  before_action :enforce_new_survey_permissions, only: [:new, :create]
  before_action :enforce_moderator_permissions, only: [:show]

  def new
    @survey = Survey.new
  end

  def show
    @survey = Survey.find(params[:id])
  end

  def create
    @survey = Survey.new(
      survey_params.merge(
        project_id: @project.id,
        issue_id: @issue.id,
        account_id: current_account.id,
        kind: @issue.reporter == current_account ? "reporter" : "respondent"
      )
    )
    if @survey.save
      send_notifications
      flash[:info] = "Thank you for completing the survey."
      redirect_to project_issue_path(@project, @issue)
    else
      flash[:error] = @survey.errors.full_messages
      render :new
    end
  end

  private

  def enforce_new_survey_permissions
    render_forbidden && return unless current_account.can_complete_survey_on_issue?(@issue, @project)
  end

  def enforce_moderator_permissions
    render_forbidden && return unless current_account.can_view_survey_on_issue?(@project)
  end

  def scope_issue
    @issue = Issue.find(params[:issue_id])
  end

  def scope_project
    @project = Project.find_by(slug: params[:project_slug])
  end

  def send_notifications
    @project.moderators.each do |moderator|
      NotificationService.notify(account: moderator, project: @project, issue_id: @issue.id)
      IssueNotificationsMailer.with(
        email: moderator.email,
        project_id: @project.id,
        issue_id: @issue.id,
        survey_id: @survey.id
      ).notify_of_new_survey.deliver
    end
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
