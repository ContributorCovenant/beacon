template = ConsequenceGuide.find_or_create_by(scope: "template")
template.consequences.destroy_all

Consequence.create(
  consequence_guide_id: template.id,
  severity: 1,
  label: "Correction",
  example: "Use of inappropriate language, such as profanity, or other behavior deemed unprofessional or unwelcome in the community.",
  consequence: "A private, written warning from project leadership, with clarity of violation and explanation of why the behavior was inappropriate."
)

Consequence.create(
  consequence_guide_id: template.id,
  severity: 2,
  label: "Warning",
  example: "A violation through a single incident or series of actions that create toxicity in the community.",
  consequence: "A warning with consequences of continued behavior. No interaction with people involved, including unsolicited interaction with those enforcing the guidelines, for a period specified by moderators. This includes avoiding interactions in any project space, as well as external channels like social media. Violating these terms may lead to a temporary or permanent ban."
)

Consequence.create(
  consequence_guide_id: template.id,
  severity: 3,
  label: "Temporary Ban",
  example: "A serious violation of community standards, including sustained inappropriate behavior or language, or targeting/harassing an individual.",
  consequence: "A temporary ban from any sort of interaction in the project community, including pull requests, issues, and comments, for a period specified by moderators. No interaction with people involved, including unsolicited interaction with those enforcing the guidelines, during this period. This includes avoiding interactions in any project space, as well as external channels like social media. Violating these terms may lead to a permanent ban."
)

Consequence.create(
  consequence_guide_id: template.id,
  severity: 4,
  label: "Permanent Ban",
  example: "Demonstrating a pattern of violation of community standards, including sustained inappropriate behavior or language,  harassment of an individual, or aggression or disparagement of class of individuals.",
  consequence: "A permanent ban from any sort of interaction in the project community, including pull requests, issues, and comments."
)

RespondentTemplate.where(is_beacon_default: true).destroy_all

RespondentTemplate.create(
  is_beacon_default: true,
  text: "This is to inform you that you have been named as a respondent on a code of conduct issue on the [[PROJECT_NAME]] project. We are contacting you as part of our investigation of this issue. For reference, you can find our code of conduct at [[CODE_OF_CONDUCT_URL]].\n\nA summary of the issue is provided here:\n\n[[ISSUE_SUMMARY]]\n\nIn the interest of fairness, we would like to give you an opportunity to respond to this issue and provide any context or additional information that may help us in our investigation.\n\nTo respond to this issue, please visit [[ISSUE_URL]]. You may be prompted to create an account on Beacon if you don't already have one.\n\nThank you in advance for your prompt attention. As moderators, we promise a fair and timely evaluation of this situation, and will do everything in our power to address this issue in a way that is respectful of both you and our shared community."
)
