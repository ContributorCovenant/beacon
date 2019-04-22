module Admin

  class AbuseReportsController < Admin::AdminController

    before_action :enforce_account_permissions
    before_action :scope_report, except: [:index]

    breadcrumb "Organizations Admin", :admin_organizations_path

    def index
      @reports = AbuseReport.all.includes(:abuse_report_subject).order("created_at DESC")
    end

    def show
      breadcrumb "Abuse Report #{@report.report_number}", admin_abuse_report_path(@report)
      @project = @report.project
      @reporter = @report.account
      @reportee = @report.reportee
    end

    def update
      @report.update_attributes(report_params)
      case params[:commit]
      when "Lock Account"
        @report.reportee.flag!(params[:admin_note])
        @report.resolve!
      when "Flag Project"
        @report.project.flag!(params[:admin_note])
        @report.resolve!
      when "Dismiss Report"
        @report.dismiss!
      end
      redirect_to admin_abuse_reports_path
    end

    private

    def enforce_account_permissions
      render_forbidden && return unless current_account.can_access_abuse_reports?
    end

    def report_params
      params.require(:abuse_report).permit(:admin_note, :flag)
    end

    def scope_report
      @report = AbuseReport.find(params[:id])
    end

  end
end
