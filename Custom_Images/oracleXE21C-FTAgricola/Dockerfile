FROM centos:7

ENV ORACLE_DOCKER_INSTALL=true

RUN yum update; \
        yum install -y epel-release; \
        yum update; \
        yum install -y dialog curl nano htop inxi sensors wget cifs-utils rsync binutils compat-libcap1 gcc gcc-c++ glibc glibc.i686 glibc-devel glibc.i686 ksh; \
        yum install -y libaio libaio.i686 libaio-devel libaio-devel.i686 libgcc libgcc.i686 libstdc++ libstdc++l7.i686 libstdc++-devel; \
        yum install -y libstdc++-devel.i686 compat-libstdc++-33 compat-libstdc++-33.i686 libXi libXi.i686 libXtst libXtst.i686 make sysstat dbus; \
        yum clean all

COPY oracle-database-preinstall-21c-1.0-1.el7.x86_64.rpm /tmp/

COPY oracle-database-xe-21c-1.0-1.ol7.x86_64.rpm /tmp/

RUN yum localinstall -y /tmp/oracle-database-preinstall-21c-1.0-1.el7.x86_64.rpm; \
        yum localinstall -y /tmp/oracle-database-xe-21c-1.0-1.ol7.x86_64.rpm; \
        rm -rf /tmp/oracle-database-preinstall-21c-1.0-1.el7.x86_64.rpm; \
        rm -rf /tmp/oracle-database-xe-21c-1.0-1.ol7.x86_64.rpm

COPY startdbus.sh /usr/local/bin
RUN chmod +x /usr/local/bin/startdbus.sh

COPY startoracle.sh /usr/local/bin
RUN chmod +x /usr/local/bin/startoracle.sh

CMD ["/bin/bash", "/usr/local/bin/startdbus.sh"]

ENTRYPOINT ["/bin/bash", "/usr/local/bin/startoracle.sh"]
