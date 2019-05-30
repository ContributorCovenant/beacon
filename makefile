dc=docker-compose -f docker-compose.yml $(1)
dc-run=$(call dc, run --rm web $(1))

usage:
	@echo "Available targets:"
	@echo "  * setup             - Initiates everything (building images, installing gems, creating db and migrating"
	@echo "  * build             - Builds all images"
	@echo "  * update-deps       - Installs missing runtime dependencies (installs bundle)"
	@echo "  * db-migrate        - Runs the migrations for development db"
	@echo "  * db-test-migrate   - Runs the migrations for the test db"
	@echo "  * dev               - Starts and connects to the docker container"
	@echo "  * run               - Runs the development server"
	@echo "  * tear-down         - Removes all the containers and tears down the setup"
	@echo "  * stop              - Stops the server and the database containers"
	@echo "  * rspec             - Runs rspec"

setup: build update-deps db-create db-migrate

build:
	$(call dc, build)
update-deps:
	$(call dc-run, bundle install)
db-create:
	$(call dc-run, bundle exec rake db:create)
db-migrate:
	$(call dc-run, bundle exec rake db:migrate)
db-test-migrate:
	$(call dc-run, RAILS_ENV=test rake db:migrate)
dev:
	$(call dc-run, ash)
console:
	$(call dc-run, bundle exec rails console)
run:
	$(call dc, up)
tear-down:
	$(call dc, down)
stop:
	$(call dc, stop)
.PHONY: rspec
rspec:
	$(call dc-run, bundle exec rspec)
