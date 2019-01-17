# frozen_string_literal: true

class IssueCommentsController < ApplicationController
  before_action :authenticate_account!
  before_action :scope_project
  before_action :scope_issue
  before_action :enforce_permissions

  def create
    comment = IssueComment.create(
      issue_id: @issue.id,
      commenter_id: current_account.id,
      visible_to_reporter: visible_to_reporter?,
      visible_to_respondent: visible_to_respondent?,
      visible_only_to_moderators: visible_only_to_moderators?,
      text: comment_params[:text]
    )
    notify_of_new_comment(comment)
    redirect_to project_issue_path(@project, @issue)
  end

  private

  def comment_params
    params.require(:issue_comment).permit(
      :text,
      :visible_to_reporter,
      :visible_to_respondent,
      :visible_only_to_moderators
    )
  end

  def scope_project
    @project = Project.find_by(slug: params[:project_slug])
  end

  def scope_issue
    @issue = Issue.find(params[:issue_id])
  end

  def notify_of_new_comment(comment)
    return if comment.visible_only_to_moderators && comment.commenter == current_account
    if comment.visible_to_reporter && @project.moderators.include?(comment.commenter)
      email = @issue.reporter.email
    elsif comment.visible_to_respondent && @project.moderators.include?(comment.commenter)
      email = @issue.respondent.email
    else
      email = @project.moderators.map(&:email)
    end
    IssueNotificationsMailer.with(
      email: email,
      project: @issue.project,
      issue: @issue,
      commenter_kind: comment.commenter_kind
    ).notify_of_new_comment.deliver_now
  end


  def visible_only_to_moderators?
    comment_params[:visible_only_to_moderators] == '1' && @project.account_can_manage?(current_account)
  end

  def visible_to_reporter?
    current_account == @issue.reporter || (@project.account_can_manage?(current_account) && comment_params[:visible_to_reporter] == '1')
  end

  def visible_to_respondent?
    current_account == @issue.respondent || (@project.account_can_manage?(current_account) && comment_params[:visible_to_respondent] == '1')
  end

  def enforce_permissions
    render(status: :forbidden, plain: nil) && return unless @issue.account_can_comment?(current_account)
  end

end
