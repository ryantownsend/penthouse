test-4.2.11.1: # Test rails 4 LTS
	RUBY_VERSION=2.3.0 RAILS_VERSION=4.2.11.1 PG_VERSION=0.21.0 docker-compose build
	RUBY_VERSION=2.3.0 RAILS_VERSION=4.2.11.1 PG_VERSION=0.21.0 docker-compose run penthouse

test-5.1.7: # Test rails 5 before migration context
	RUBY_VERSION=2.4.0 RAILS_VERSION=5.1.7 PG_VERSION=0.21.0 docker-compose build
	RUBY_VERSION=2.4.0 RAILS_VERSION=5.1.7 PG_VERSION=0.21.0 docker-compose run penthouse

test-5.2.3: # Test rails 5 with migration context
	RUBY_VERSION=2.5.0 RAILS_VERSION=5.2.3 PG_VERSION=1.1.4 docker-compose build
	RUBY_VERSION=2.5.0 RAILS_VERSION=5.2.3 PG_VERSION=1.1.4 docker-compose run penthouse

test-6.0.0: # Test rails 6
	RUBY_VERSION=2.6.0 RAILS_VERSION=6.0.0 PG_VERSION=1.1.4 docker-compose build
	RUBY_VERSION=2.6.0 RAILS_VERSION=6.0.0 PG_VERSION=1.1.4 docker-compose run penthouse

test:
	make test-4.2.11.1
	make test-5.1.7
	make test-5.2.3
