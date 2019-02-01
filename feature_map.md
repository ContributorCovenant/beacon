# CoC Beacon Feature Overview

## Prototype Features

* Basic account creation
* Basic project configuration including public/private status, links to code of conduct, project description, and general issue policies
* Moderators can rate-limit the number of issues they will accept in a 24-hour period
* Moderators can pause and resume accepting issues filed in their projects
* Directory of projects that are public
* Ability to open an issue in a project including a description of the issue and screenshots
* Moderators have access to a dashboard of open, in-progress, dismissed, and resolved issues per project
* Moderators can acknowledge, dismiss, or resolve an issue
* Moderatore can add comments to an issue
* Moderators can send messages to a reporter and those messages are visible from the issue dashboard
* Reporters can respond to moderator comments and have their own view of the issue (without seeing moderator-only information)
* Subjects of issues can receive an email with a one-use URL linking them to the issue
* Subjects of issues can create an account
* Subjects of issues can comment on an issue and see moderator responses to their comments
* Moderators can send messages to a subject and those messages are visible from the issue dashboard
* Moderators can create a template for initial contact with an issue’s subject
* Moderators can block reporters and respondents
* Users can report projects for abuse
* Moderators can see a history of issues for reporters and respondents
* Moderators have a step-by-step setup process with a clear progress indicator
* Creation and display of a "consequence ladder" per project (detailing examples of unacceptable behavior and their likely consequences)
* Per-project block lists of reporters
* Prototype will be accessible on a temporary server setup on Heroku
* CI and automated deployments

## Prototype security features
* Accounts are locked after a certain number of failed login attempts
* Fully integrated reCAPTCHA, with accessibility features, on account creation and issue creation
* Links between issues, reporters, subjects, moderators, and projects are all encrypted in the database. This means that if someone gets access to the database, they will not be able to recreate the association between an issue and the reporter, etc.
* All displays of issue details are watermarked with a hash that can be linked to an account, so if someone takes a screenshot of an issue we can trace the leak back to a given account
* Email validation required to activate an account
* Validation of uniqueness of email addresses to prevent mass creation of junk accounts (e.g. john.smith@gmail.com, johnsmith@gmail.com, johnsmith+test@gmail.com)
* Record instances of a user attempting to access a forbidden resource or page

## Public beta features

### For moderators and project owners
* Ability to add moderators (beyond the project owner) to a project
* Ability to create organizations with multiple projects
* Organization-wide issue dashboard
* Ability to invite participants to an organization
* Inherit project settings and consequence ladders across all projects in an organization
* Distinction between an organization's moderators and a list of email addresses for CoC management reporting (e.g. "these five people should be informed of issues but they are not moderators")
* Ability to configure and follow a moderation consensus plan (e.g. 2/3 of moderators must agree before closing an issue)
* Ability to restrict low-reputation accounts from opening issues (project configuration)
* Projects are required to place a token proving ownership in their project’s repository or web site
* Ability to mark an issue as spam/abuse/harassment
* Rolling three-month transparency reporting on project performance

### For reporters
* Issue reporters can rate their satisfaction with outcomes once an issue is resolved

### For Beacon administrators
* Beacon administrators have the responsibility to review and approve projects prior to them being public
* Superuser dashboards and controls for account and project management

### Additional security features
* SMS 2fa on account creation and sign in
* Phone number uniqueness validation
* Linking accounts to GitHub or GitLab accounts
* Sign in with GitHub or GitLab credentials
* Global rate-limiting for opening issues
* Reporter reputation system
* Number of dismissed/spam issues
* Traffic source (Tor exit nodes, proxies)
* Number of resolved issues with the reporter as the subject
* Suspicious site activity (pattern of triggering 404s and 302s)

### Additional post-prototype effort
* UI/UX/accessibility improvements
* Consultation with community management and code of conduct enforcement specialists
* Security audit
* Hosting and ops

