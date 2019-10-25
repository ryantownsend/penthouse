build:
	docker build --build-arg RUBY_VERSION=$(ruby) -t penthouse/ruby-$(ruby) .

run:
	docker run penthouse/ruby-$(ruby) -e "RUBY_VERSION=$(ruby)" ${args}

bundle-install:
	make run ruby=$(ruby) rails=$(rails) pg=$(pg) args="bundle exec install"

