FROM centos:7

LABEL maintainer="oatkrittin@gmail.com"

ENV R_SLURM_SIM_TOOLS_HOME=/usr/local/src 
ENV DEV_USER=dev
ENV DEV_USER_PASSWORD="devsecret"

ADD src $R_SLURM_SIM_TOOLS_HOME

RUN useradd $DEV_USER -m && \
  echo "${DEV_USER}:${DEV_USER_PASSWORD}" | chpasswd

RUN yum -y update && \
    yum -y install epel-release && \
    yum -y install \
    gcc-c++ \
    R \
    R-Rcpp \
    R-Rcpp-devel \
	  python-devel \
    texlive-* \
    wget \
    supervisor \
    && \
    yum clean all

RUN Rscript /scripts/package_install.R
RUN wget https://download2.rstudio.org/rstudio-server-rhel-1.1.453-x86_64.rpm && \
    yum -y install rstudio-server-rhel-1.1.453-x86_64.rpm && \
    rm -f rstudio-server-rhel-1.1.453-x86_64.rpm

EXPOSE 8787

ADD scripts /scripts
ADD etc/supervisord.d/rserver.ini /etc/supervisord.d/rserver.ini

RUN chmod -R a+rwx /scripts && \
    mkdir -p /var/log/supervisor

WORKDIR /home/dev

VOLUME [ "/home/dev" ]

CMD ["/usr/bin/supervisord", "--nodaemon"]