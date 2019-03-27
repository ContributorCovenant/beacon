module Admin

  class AccountsController < Admin::AdminController

    before_action :enforce_account_permissions
    before_action :scope_account, except: [:index]

    breadcrumb "Accounts Admin", :admin_accounts_path

    def index
      @accounts = Account.all.order("email ASC")
    end

    def show
      breadcrumb @account.display_name, admin_account_path(@account)
      @blocks = @account.account_project_blocks.map(&:project)
      @reports = AbuseReportSubject.where(account_id: @account.id).includes(:abuse_report)
      @projects = @account.projects
      @organizations = @account.organizations
      @log = @account.account_activity_log
    end

    def flag
      @account.flag!(flag_account_params[:flagged_reason])
      ActivityLoggingService.log(@account, :times_flagged)
      redirect_to admin_account_path(@account)
    end

    def unflag
      @account.unflag!
      redirect_to admin_account_path(@account)
    end

    private

    def enforce_account_permissions
      render_forbidden && return unless current_account.can_access_admin_account_dashboard?
    end

    def flag_account_params
      params.require(:account).permit(:flagged_reason)
    end

    def scope_account
      @account = Account.find_by(id: params[:id]) || Account.find_by(id: params[:account_id])
    end

  end

end
