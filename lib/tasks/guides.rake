namespace :guides do

  desc "Create defaults"
  task :create_defaults => :environment do
    template = ConsequenceGuide.find_or_create_by(scope: "template")
    template.consequences.destroy_all
    Consequence.create(
      consequence_guide_id: template.id,
      severity: 1,
      label: "Correction",
      action: "Use of inappropriate language, such as profanity, or other behavior deemed unprofessional or unwelcome in the community.",
      consequence: "A private, written warning from project leadership, with clarity of violation and explanation of why the behavior was inappropriate."
    )

    Consequence.create(
      consequence_guide_id: template.id,
      severity: 2,
      label: "Warning",
      action: "A violation through a single incident or series of actions that create toxicity in the community.",
      consequence: "A warning with consequences of continued behavior. No interaction with people involved, including unsolicited interaction with those enforcing the guidelines, for a period specified by moderators. This includes avoiding interactions in any project space, as well as external channels like social media. Violating these terms may lead to a temporary or permanent ban."
    )

    Consequence.create(
      consequence_guide_id: template.id,
      severity: 3,
      label: "Temporary Ban",
      action: "A serious violation of community standards, including sustained inappropriate behavior or language, or targeting/harassing an individual.",
      consequence: "A temporary ban from any sort of interaction in the project community, including pull requests, issues, and comments, for a period specified by moderators. No interaction with people involved, including unsolicited interaction with those enforcing the guidelines, during this period. This includes avoiding interactions in any project space, as well as external channels like social media. Violating these terms may lead to a permanent ban."
    )

    Consequence.create(
      consequence_guide_id: template.id,
      severity: 4,
      label: "Permanent Ban",
      action: "Demonstrating a pattern of violation of community standards, including sustained inappropriate behavior or language,  harassment of an individual, or aggression or disparagement of class of individuals.",
      consequence: "A permanent ban from any sort of interaction in the project community, including pull requests, issues, and comments."
    )
  end

  desc 'Map project issue severity levels to new guides'
  task :update_project_guides => :environment do
    Project.all.each do |project|
      guide = ConsequenceGuide.create(project_id: project.id)
      project.issue_severity_levels.each do |level|
        Consequence.create(
          consequence_guide_id: guide.id,
          severity: level.severity,
          label: level.label,
          action: level.example,
          consequence: level.consequence
        )
      end
    end
  end

  desc 'Map organization issue severity levels to new guides'
  task :update_org_guides => :environment do
    Organization.all.each do |organization|
      guide = ConsequenceGuide.create(organization_id: organization.id)
      organization.issue_severity_levels.each do |level|
        Consequence.create(
          consequence_guide_id: guide.id,
          severity: level.severity,
          label: level.label,
          action: level.example,
          consequence: level.consequence
        )
      end
    end
  end

end
