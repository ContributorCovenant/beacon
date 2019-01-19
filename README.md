# Beacon

[![Build Status](https://travis-ci.com/ContributorCovenant/beacon.svg?branch=release)](https://travis-ci.com/ContributorCovenant/beacon)

## Background

Over the past several years, code of conduct adoptions by open source projects have become the norm for open source project. However, enforcement of a code of conduct is the real key to creating welcoming and inclusive community comprising a diverse set of participants.

But up to now, only the largest open source projects have had access to the kinds of resources that make enforcement even possible, let alone fair and manageable.

Beacon was created with the goal of bringing this potential to every open source project, large or small. It gives project maintainers a complete set of tools for managing their communities: setting up their enforcement teams, documenting their processes, managing code of conduct issues, forming consensus around enforcement decisions, and communicating clearly and fairly with reporters and respondents.

Beacon will be provided in a software-as-a-service (SaaS) model to reduce friction for getting started, so that maintainers can focus on managing their projects and communities with a minimum of setup.

## Milestones

* **January 2019:** We are currently working towards finishing an initial prototype. [Project board](https://github.com/ContributorCovenant/beacon/projects/1)
* **February 2019:** Work with select stakeholders representing a variety of different kinds of open source projects to ensure that Beacon satisfies their needs.
* **April 2019:** Open a limited public beta
* **June 2019:** Official launch

## Supporting Beacon
You can show your support for Beacon and help fund its development through [monthly contributions to our Patreon](https://www.patreon.com/cocbeacon) or a [one-time donation to our fundraiser](https://www.gofundme.com/coc-beacon).

## Contributing Code to Beacon
All contributions, including pull requests, issues, and comments, are governed by our [code of conduct](https://github.com/ContributorCovenant/beacon/blob/release/CODE_OF_CONDUCT.md).

### Adding gems
If you are adding a new gem, be sure to place it in the proper section of the `GEMFILE` in alphabetical order.

### Passing specs
Make sure there are no test failures:

`bundle exec rspec spec/`

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

`rails s`

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
