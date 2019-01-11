# frozen_string_literal: true

class IssueCommentsController < ApplicationController
  before_action :scope_project_and_issue

  def new
    @comment = IssueComment.new
  end

  def create
    comment = IssueComment.new(issue_id: @issue.id, commenter_id: current_account.id)
    comment.visible_to_reporter = comment_params[:visible_to_reporter] == '1'
    comment.text = comment_params[:text]
    comment.save
    redirect_to project_issue_path(@project, @issue)
  end

  private

  def comment_params
    params.require(:issue_comment).permit(:text, :visible_to_reporter)
  end

  def scope_project_and_issue
    @project = Project.find_by(slug: params[:project_slug])
    @issue = Issue.find(params[:issue_id])
  end
end
