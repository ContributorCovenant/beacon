class ProjectMailer < ApplicationMailer
  def name_change(params)
    @project = Project.find(params[:id])
    @current_name = @project.name
    @previous_name = params[:previous_name]

    mail to: @project.account.email
  end
end
