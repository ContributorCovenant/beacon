# Contributing Code to Beacon
All contributions, including pull requests, issues, and comments, are governed by our [code of conduct](https://github.com/ContributorCovenant/beacon/blob/release/CODE_OF_CONDUCT.md).

## General guidelines
We prefer small, focused pull requests that do one thing and that can be rolled back easily. If you are working on a larger feature, please split your work into bite-sized pull requests and use the description field to connect each small PR to the others in the series, for example:

```
This is the first PR related to [feature]. It does [thing] in the [example] view, which will allow us to do [other thing] in the near future.
```

Your PR may be rejected if you try to change too much too quickly. Major shifts in technology (i.e. replacing gem x with gem y or UI framework a with b) must go through an "RFC" process so that the community and core team may weigh in. In a case like this, please open an issue to discuss your proposed approach before beginning any work.

## Claiming bugs or features
If you intend to work on a bug or feature marked "Help Wanted", please leave a comment in the issue indicating that you will be working on it along with a target completion date. Report your ongoing status in additional comments.

If you are interested in working on a feature that is not explicitly marked "Help Wanted", you must ask the project maintainers for approval in an issue comment prior to claiming the issue.

## Paid contributions
We are in the process of securing funding for the 1.0 release of Beacon. Pending successful funding, we are committed to paying contributors for their contributions to the project according to the size of the feature as indicated in its label:

* **Small feature or bug:** $400
* **Medium feature:** $1200
* **Large feature:** $2400
* **X-Large feature:** these features are generally not available for anyone outside of the core team. If you are interested in working on one of these features, you must secure permission from maintainers in advance. Maintainers will negotiate with you on the pay rate.

Payment for contributions is contingent on your pull request being approved and merged. As we will be invoicing our funding organization monthly, you will be paid within 30 days of the end of the month in which the work was completed.

## Requirements for contributions

### Adding gems
If you are adding a new gem, be sure to place it in the proper section of the `GEMFILE` in alphabetical order.

### Adding tests
Your tests should generally include both unit tests and controller tests (features). Follow the style and pattern of existing specs. If the feature you are working on impacts the workflow of a reporter, respondent, or moderator, be sure to add your feature spec to the corresponding spec file in `spec/features`.

### Passing specs
Make sure there are no test failures:

`bundle exec rspec spec/`

### Test coverage
We have a target minimum test coverage of 85%. At the end of your rspec test run, code coverage for the specs that you have run will be reported.

### Coding style
Make sure there are no code style violations:

`bundle exec rubocop`

### Security
Make sure that you have not introduced a security vulnerability:

`bundle exec brakeman`

## Local setup (non-Docker)

* Set up your environment variables for local development

`cp .env.development.sample .env.development`

* Install gems

`bundle`

* Create the database

`bundle exec rake db:create:all`

* Migrate the database

`bundle exec rake db:migrate`

* Seed the database

`bundle exec rake db:seed`

* Start the application

`rails server`

* Visit [http://localhost:3000](http://localhost:3000) in your browser

## Developing in a dockerized environment

### Setup

Set the following values in `.env.development`

    - DATABASE_HOST=db
    - DATABASE_USERNAME=postgres
    - DATABASE_PASSWORD=postgres

* run `make setup`

### Updating dependencies

After changing the gemfile, you can either run

`make update-deps` OR `make dev` then `bundle install`

### Migrating the database schema

After adding the migration, you can either run

`make db-migrate` OR `make dev` then `rake db:migrate`

### Adding seed data

`make dev` then `rake db:seed`

### Running the specs

`make rspec` OR `make dev` then `rspec`

### Running locally in a container

Use the command `make run` and visit [http://localhost:3000/](http://localhost:3000/)
