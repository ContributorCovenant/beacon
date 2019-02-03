namespace :defaults do

  desc 'Create default respondent template'
  task :respondent_template => :environment do
    RespondentTemplate.where(is_beacon_default: true).map(&:destroy)
    text = %{
This is to inform you that you have been named as a respondent on a code of conduct issue on the [[PROJECT_NAME]] project. We are contacting you as part of our investigation of this issue. For reference, you can find our code of conduct at [[CODE_OF_CONDUCT_URL]].

A summary of the issue is provided here:

(Summarize the issue)

In the interest of fairness, we would like to give you an opportunity to respond to this issue and provide any context or additional information that may help us in our investigation.

To respond to this issue, please visit [[ISSUE_URL]]. You may be prompted to create an account on Beacon if you don't already have one.

Thank you in advance for your prompt attention. As moderators, we promise a fair and timely evaluation of this situation, and will do everything in our power to address this issue in a way that is respectful of both you and our shared community.
    }

    RespondentTemplate.create(
      is_beacon_default: true,
      text: text
    )
  end

end
