class AbuseReportsController < ApplicationController

  before_action :authenticate_account!
  before_action :scope_project
  before_action :enforce_permissions

  def new
    @abuse_report = AbuseReport.new(account: current_account)
  end

  def create
    if abuse_report_params[:description].empty?
      flash[:error] = "You must provide an explanation."
      redirect_to new_abuse_report_path(project_slug: @project.slug) && return
    end
    # Only allow one submitted abuse report per project
    previous_reports = AbuseReportSubject.where(project_id: @project.id).includes(:abuse_report)
    unless previous_reports.map(&:abuse_report).find{ |report| report.aasm_state == "submitted" }
      report = AbuseReport.create!(
        account: current_account,
        description: abuse_report_params[:description],
        project: @project
      )
      AdminMailer.with(
        report_id: report.id,
        project_id: @project.id
      ).notify_on_abuse_report.deliver
    end
    flash[:message] = "Your report has been sent to Beacon administrative staff for review."
    redirect_to root_path
  end

  private

  def abuse_report_params
    params.require(:abuse_report).permit(:description)
  end

  def enforce_permissions
    render_forbidden && return unless current_account.can_report_abuse?(@project)
  end

  def scope_project
    @project = Project.find_by(slug: params[:project_slug])
  end

end
