
FROM ruby:2.5.1-stretch
MAINTAINER SubPoint Solutions Team "support@subpointsolutions.au"

# metabox gems
RUN su - root -c "gem install bundler -v 1.15.4 --no-ri --no-rdoc \
                && gem install rake -v 10.4.2 --no-ri --no-rdoc \
                && gem install rspec -v 3.6.0 --no-ri --no-rdoc \
                && gem install simplecov-bamboo -v 0.1.0 --no-ri --no-rdoc \
                && gem install coderay -v 1.1.2 --no-ri --no-rdoc \
                && gem install guard -v 2.14.1 --no-ri --no-rdoc \
                && gem install guard-rspec -v 4.7.3 --no-ri --no-rdoc \ 
                && gem install rschema -v 3.2.0 --no-ri --no-rdoc"

WORKDIR /metabox