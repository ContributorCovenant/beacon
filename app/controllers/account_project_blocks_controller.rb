class AccountProjectBlocksController < ApplicationController

  before_action :authenticate_account!
  before_action :scope_project
  before_action :enforce_permissions

  def index
    breadcrumb @project.name, project_path(@project)
    @blocks = @project.account_project_blocks.includes(:account)
    @issues = @project.issues
  end

  def create
    @block = @project.account_project_blocks.new(
      account_id: block_params[:account_id],
      reason: block_params[:reason]
    )
    if @block.save
      ActivityLoggingService.log(Account.find(block_params[:account_id]), :times_blocked)
      if block_params[:report_for_abuse]
        @account = Account.find(block_params[:account_id])
        @account.update_attributes(
          flag_requested: true,
          flag_requested_reason: block_params[:reason]
        )
        # Only create an abuse report if there are no existing 'submitted'
        # abuse reports about this reportee from the current user
        unless current_account.submitted_abuse_report_for?(@account)
          @report = AbuseReport.create!(
            account: current_account,
            description: block_params[:reason],
            reportee: @account
          )
          notify_on_account_flag_requested
        end
      end

      if params[:return_to] == "respondent"
        redirect_to project_respondent_url(@project, id: block_params[:account_id])
      elsif params[:return_to] == "reporter"
        redirect_to project_reporter_url(@project, id: block_params[:account_id])
      else
        redirect_to project_account_project_blocks_url(@project)
      end
    else
      flash[:error] = @block.errors.full_messages
      render :new
    end
  end

  def destroy
    block = @project.account_project_blocks.find(params[:id])
    block.destroy
    redirect_to project_account_project_blocks_url(@project)
  end

  private

  def enforce_permissions
    render_forbidden && return unless current_account.can_block_account?(@project)
  end

  def block_params
    params.require(:account_project_block).permit(:account_id, :reason, :report_for_abuse)
  end

  def notify_on_account_flag_requested
    AdminMailer.with(
      reporter_id: current_account.id,
      account_id: @account.id,
      report_id: @report.id,
      reason: block_params[:reason]
    ).notify_on_flag_request.deliver!
  end

  def scope_project
    @project = Project.where(slug: params[:project_slug]).includes(:account_project_blocks).first
  end

end
