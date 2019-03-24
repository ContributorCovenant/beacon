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

  end

  desc 'Create default autoresponder'
  task :autoresponder => :environment do
    autoresponder = Autoresponder.find_or_create_by(scope: "template")
    autoresponder.text = %{
Thank you for opening a code of conduct issue for [[PROJECT_NAME]].

We take code of conduct violations very seriously. We commit to you that we will fully investigate the issue, with fairness and the health of our community at the forefront.

One of our moderators will acknowledge your issue within 24 hours. You will receive an email notification when this occurs. At this point, our investigation will begin. You can message the moderators with additional details using the contact form at the bottom of the issue page. You can also attach additional screenshots as needed. Moderators can respond to your messages, and you will also receive a notification when this occurs.

For your safety and security, the respondent (the person named in your issue) will not be able to see the issue description that you have provided, nor any subsequence communication between you and the moderators. The respondent will also not be given any identifying information about you.

You can reference the Community Impact and Consequences guide on our project page at [[PROJECT_URL]] for more information. You can also see our code of conduct at [[CODE_OF_CONDUCT_URL]].

Thank you again, and please feel free to reach out should you have any questions about this issue or our enforcement policies.
    }
    autoresponder.save
  end

  desc 'Apply default autoresponder to organizations and projects'
  task :apply_default_autoresponder => :environment do
    autoresponder = Autoresponder.find_by(scope: "template")
    Organization.all.each do |organization|
      Autoresponder.create(
        organization_id: organization.id,
        text: autoresponder.text
      )
    end
    Project.all.each do |project|
      Autoresponder.create(
        project_id: project.id,
        text: autoresponder.text
      )
    end
  end

end
