module Admin

  class ProjectsController < Admin::AdminController

    before_action :enforce_project_permissions
    before_action :scope_project, except: [:index]

    def index
      @projects = Project.all.includes(:account).order('name ASC')
    end

    def show
      issues = @project.issues.order("created_at DESC")
      @total_issues = issues.count
      @submitted_issues = issues.select{ |issue| issue.aasm_state == "submitted" }
      @acknowledged_issues = issues.select{ |issue| %w{acknowledged reopened}.include? issue.aasm_state }
      @dismissed_issues = issues.select{ |issue| issue.aasm_state == "dismissed" }
      @resolved_issues = issues.select{ |issue| issue.aasm_state == "resolved" }
      @blocked_accounts = @project.account_project_blocks.includes(:account).map(&:account)
    end

    def flag
      @project.flag!(flag_project_params[:flagged_reason])
      redirect_to admin_project_path(@project)
    end

    def unflag
      @project.unflag!
      redirect_to admin_project_path(@project)
    end

    private

    def enforce_project_permissions
      render_forbidden && return unless current_account.can_access_admin_project_dashboard?
    end

    def flag_project_params
      params.require(:project).permit(:flagged_reason)
    end

    def scope_project
      @project = Project.find_by(slug: params[:slug]) || Project.find_by(slug: params[:project_slug])
      @settings = @project.project_setting
    end

  end

end
