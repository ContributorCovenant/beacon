class RespondentMailerPreview < ActionMailer::Preview

  def notify_existing_account_of_issue
    params = {
      project_name: "Foo Gem",
      email: "foo@bar.com"
    }
    RespondentMailer.with(params).notify_existing_account_of_issue
  end

  def notify_new_account_of_issue
    params = {
      project_name: "Foo Gem",
      email: "foo@bar.com"
    }
    RespondentMailer.with(params).notify_new_account_of_issue
  end

end
