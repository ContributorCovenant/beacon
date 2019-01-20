IssueSeverityLevel.create(
  scope: "template",
  severity: 1,
  label: "Correction",
  example: "Use of inappropriate language, such as profanity, or other behavior deemed unprofessional or unwelcome in the community.",
  consequence: "A private, written warning from project leadership, with clarity of violation and explanation of why the behavior was inappropriate."
)

IssueSeverityLevel.create(
  scope: "template",
  severity: 2,
  label: "Warning",
  example: "A violation through a single incident or series of actions that create toxicity in the community.",
  consequence: "A warning with consequences of continued behavior. No interaction with people involved, including unsolicited interaction with those enforcing the guidelines, for a period specified by moderators. This includes avoiding interactions in any project space, as well as external channels like social media. Violating these terms may lead to a temporary or permanent ban."
)

IssueSeverityLevel.create(
  scope: "template",
  severity: 3,
  label: "Temporary Ban",
  example: "A serious violation of community standards, including sustained inappropriate behavior or language, or targeting/harassing an individual.",
  consequence: "A temporary ban from any sort of interaction in the project community, including pull requests, issues, and comments, for a period specified by moderators. No interaction with people involved, including unsolicited interaction with those enforcing the guidelines, during this period. This includes avoiding interactions in any project space, as well as external channels like social media. Violating these terms may lead to a permanent ban."
)

IssueSeverityLevel.create(
  scope: "template",
  severity: 4,
  label: "Permanent Ban",
  example: "Demonstrating a pattern of violation of community standards, including sustained inappropriate behavior or language,  harassment of an individual, or aggression or disparagement of class of individuals.",
  consequence: "A permanent ban from any sort of interaction in the project community, including pull requests, issues, and comments, for a period specified by moderators."
)
