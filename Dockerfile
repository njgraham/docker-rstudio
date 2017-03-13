FROM centos
# From https://www.rstudio.com/products/rstudio/download-server/
ARG RSTUDIO_RPM=rstudio-server-rhel-1.0.136-x86_64.rpm
# TODO: Verify the hash
ARG RSTUDIO_MD5=ed7ebef1eb47f19cdfe05288b77c3336

RUN yum -y install epel-release && yum -y update && yum install -y R wget
RUN wget https://download2.rstudio.org/${RSTUDIO_RPM} && \
    echo  "${RSTUDIO_MD5} ${RSTUDIO_RPM}" | md5sum -c - && \
    yum install -y --nogpgcheck ${RSTUDIO_RPM}
COPY rserver.conf /etc/rstudio/
COPY rsession.conf /etc/rstudio/

# LDAP
RUN yum -y install openldap openldap-clients nss_ldap

ENV TINI_VERSION v0.14.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini.asc /tini.asc
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7 \
 && gpg --verify /tini.asc

RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]
CMD ["/usr/lib/rstudio-server/bin/rserver", "--server-daemonize", "0"]
CMD ["/tini", "-vvv", "--", "/usr/lib/rstudio-server/bin/rserver", "--server-daemonize", "0"]

# Supervisor
#RUN yum -y install supervisor
#COPY ./rstudio_supervisor.ini /etc/supervisord.d/
#CMD ["/usr/bin/supervisord", "-n"]