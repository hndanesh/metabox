FROM jenkins/jenkins:lts

# install plugins, check base doco on how it works
# https://hub.docker.com/r/jenkins/jenkins/
COPY jenkins2/plugins/plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

# copy all init.groovy.d scripts
COPY jenkins2/init.groovy.d/* /usr/share/jenkins/ref/init.groovy.d/

# Skip initial setup
# search on github for more details
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

COPY jenkins2/pipelines/* /app/jenkins2/pipelines/