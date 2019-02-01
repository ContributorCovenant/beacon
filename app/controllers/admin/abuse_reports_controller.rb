module Admin

  class AbuseReportsController < Admin::AdminController

    before_action :enforce_account_permissions
    before_action :scope_report, except: [:index]

    def index
      @reports = AbuseReport.all.includes(:abuse_report_subject).order("created_at DESC")
    end

    def show
      @project = @report.project
      @reporter = @report.account
    end

    def update
      @report.update_attributes(report_params)
      @report.resolve! if params[:commit] == "Resolve Report"
      @report.dismiss! if params[:commit] == "Dismiss Report"
      redirect_to admin_abuse_reports_path
    end

    private

    def enforce_account_permissions
      render_forbidden && return unless current_account.can_access_abuse_reports?
    end

    def report_params
      params.require(:abuse_report).permit(:admin_note)
    end

    def scope_report
      @report = AbuseReport.find(params[:id])
    end

  end
end
