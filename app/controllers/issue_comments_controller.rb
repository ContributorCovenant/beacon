# frozen_string_literal: true

class IssueCommentsController < ApplicationController
  before_action :scope_project
  before_action :scope_issue
  before_action :enforce_permissions

  def create
    comment = IssueComment.new(issue_id: @issue.id, commenter_id: current_account.id)
    comment.visible_to_reporter = comment_params[:visible_to_reporter] == '1'
    comment.visible_to_respondent = comment_params[:visible_to_respondent] == '1'
    comment.text = comment_params[:text]
    comment.save
    redirect_to project_issue_path(@project, @issue)
  end

  private

  def comment_params
    params.require(:issue_comment).permit(:text, :visible_to_reporter, :visible_to_respondent)
  end

  def scope_project
    @project = Project.find_by(slug: params[:project_slug])
  end

  def scope_issue
    @issue = Issue.find(params[:issue_id])
  end

  def enforce_permissions
    render(status: :forbidden, plain: nil) && return unless @issue.account_can_comment?(current_account)
  end

end
