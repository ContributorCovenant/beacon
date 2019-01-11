# Beacon

##Background

Over the past several years, code of conduct adoptions by open source projects has become the norm for establishing and communicating community values. However, enforcement of a code of conduct is the real key to creating welcoming and inclusive communities.

But up to now, only the largest open source projects have had access to the kinds of resources that make enforcement even possible, let alone fair and manageable.

CoC Beacon is an open source project with the goal of bringing this potential to every open source project, large or small. CoC Beacon will provide project maintainers with a complete set of tools for managing their codes of conduct at all stages: setting up their enforcement teams, documenting their processes, reporting incidents, managing incident reports, forming consensus about enforcement decisions, and communicating clearly with reporters and offenders.

CoC Beacon will be provided in a software-as-a-service (SaaS) model to reduce friction for getting started, so that maintainers can focus on managing their projects and communities with a minimum of setup.

## Contribution notes
To use the dockerized environment:

### To setup

* After cloning the repo
* copy the env sample
    `cp .env.development-docker.sample .env.development`
* run `make setup`

### To run locally
* use the command `make run` and visit http://localhost:3000/

### To update dependencies
* After changing the gemfile, you can either run 

`make update-deps`OR `make dev` then `bundle install`

### To migrate the database schema
* After adding the migration, you can either run 

`make db-migrate`OR `make dev` then `rake db:migrate`

### To run the specs
`make rspec` OR `make dev` then `rspec`

