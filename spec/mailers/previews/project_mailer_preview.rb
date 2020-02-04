# Preview all emails at http://localhost:3000/rails/mailers/project_mailer
class ProjectMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/project_mailer/name_change
  def name_change
    ProjectMailerMailer.name_change
  end

end
