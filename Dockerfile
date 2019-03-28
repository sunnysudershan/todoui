FROM  rhel7:7.5

MAINTAINER Red Hat Training <training@redhat.com>

# DocumentRoot for Apache
ENV HOME /var/www/html

# Need this for installing HTTPD from classroom yum repo
ADD training.repo /etc/yum.repos.d/training.repo
RUN yum downgrade -y krb5-libs libstdc++ libcom_err && \
    yum install -y --setopt=tsflags=nodocs \
    httpd \
    openssl-devel \
    procps-ng \
    which && \
    yum clean all -y && \
    rm -rf /var/cache/yum

# Custom HTTPD conf file to log to stdout as well as change port to 8080
COPY conf/httpd.conf /etc/httpd/conf/httpd.conf

# Copy front end static assets to HTTPD DocRoot
COPY src/ ${HOME}/

# We run on port 8080 to avoid running container as root
EXPOSE 8080

# This stuff is needed to make HTTPD run on OpenShift and avoid
# permissions issues
RUN rm -rf /run/httpd && mkdir /run/httpd && chmod -R a+rwx /run/httpd

# Run as apache user and not root
USER 1001

# Launch apache daemon
CMD /usr/sbin/apachectl -DFOREGROUND