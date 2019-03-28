class IssueCommentsController < ApplicationController
  before_action :authenticate_account!
  before_action :scope_project
  before_action :scope_issue
  before_action :enforce_permissions

  def create
    @comment = IssueComment.new(issue_id: @issue.id, commenter_id: current_account.id)
    @comment.visible_to_reporter = visible_to_reporter?
    @comment.visible_to_respondent = visible_to_respondent?
    @comment.visible_only_to_moderators = visible_only_to_moderators?
    @comment.text = comment_params[:text]
    @comment.context = comment_params[:context]
    @comment.save
    send_notifications
    respond_to do |f|
      f.html { redirect_to project_issue_path(@project, @issue) }
      f.js {}
    end
  end

  private

  def comment_params
    params.require(:issue_comment).permit(
      :text,
      :visible_to_reporter,
      :visible_to_respondent,
      :visible_only_to_moderators,
      :context
    )
  end

  def enforce_permissions
    render_forbidden && return unless current_account.can_comment_on_issue?(@issue)
  end

  def scope_issue
    @issue = Issue.find(params[:issue_id])
  end

  def scope_project
    @project = Project.where(slug: params[:project_slug]).includes(:account).first
  end

  def visible_only_to_moderators?
    comment_params[:visible_only_to_moderators] == '1' && @project.moderator?(current_account)
  end

  def visible_to_reporter?
    current_account == @issue.reporter || (@project.moderator?(current_account) && comment_params[:visible_to_reporter] == '1')
  end

  def visible_to_respondent?
    current_account == @issue.respondent || (@project.moderator?(current_account) && comment_params[:visible_to_respondent] == '1')
  end

  def send_notifications
    if @project.moderator?(current_account) && visible_to_reporter?
      email = @issue.reporter.email
      commenter_kind = "moderator"
      NotificationService.enqueue_notification(account_id: @issue.reporter.id,
                                              project_id: @project.id,
                                              issue_id: @issue.id,
                                              issue_comment_id: @comment.id)
    elsif @project.moderator?(current_account) && visible_to_respondent?
      email = @issue.respondent.email
      commenter_kind = "moderator"
      NotificationService.enqueue_notification(account_id: @issue.respondent.id,
                                              project_id: @project.id,
                                              issue_id: @issue.id,
                                              issue_comment_id: @comment.id)

    elsif @comment.commenter == @issue.reporter
      email = @project.moderator_emails
      commenter_kind = "reporter"
    elsif @comment.commenter == @issue.respondent
      email = @project.moderator_emails
      commenter_kind = "respondent"
    else
      email = @project.moderator_emails
      commenter_kind = "moderator"
    end

    if email == @project.moderator_emails
      unnotified_moderators = @project.moderators.reject do |moderator|
        moderator.notification_on_issue_of_kind?(@issue.id, commenter_kind)
      end
      @project.moderators.each do |moderator|
        next if moderator == current_account
        NotificationService.enqueue_notification(account_id: moderator.id,
                                                project_id: @project.id,
                                                issue_id: @issue.id,
                                                issue_comment_id: @comment.id)
      end
      if unnotified_moderators.any?
        IssueNotificationsMailer.with(
          email: unnotified_moderators.map(&:email),
          project: @project,
          issue: @issue,
          commenter_kind: commenter_kind
        ).notify_of_new_comment.deliver_now
      end
    else
      IssueNotificationsMailer.with(
        email: email,
        project: @project,
        issue: @issue,
        commenter_kind: commenter_kind
      ).notify_of_new_comment.deliver_now
    end
  end

end
