FROM mariadb:10.0
MAINTAINER Matt Duren <matthewduren@gmail.com>

RUN apt-get update && \
    apt-get -y dist-upgrade

# Install mydumper and mysql client
RUN apt-get -y install wget \
                       mysql-client-core-5.5 \
                       git \
                       python-setuptools \
                       cmake \
                       libglib2.0-dev \
                       zlib1g-dev \
                       libpcre3-dev \
                       libmysqlclient18 \
                       build-essential \
                       libmariadbclient-dev \
                       libssl-dev

RUN easy_install -U Sphinx

# Install s3cmd
RUN git clone https://github.com/s3tools/s3cmd && cd s3cmd && python setup.py install

RUN echo "innodb_large_prefix=on" >> /etc/mysql/conf.d/mariadb.cnf
RUN echo "innodb_file_format=BARRACUDA" >> /etc/mysql/conf.d/mariadb.cnf

# Install mydumper
RUN wget https://launchpad.net/mydumper/0.6/0.6.2/+download/mydumper-0.6.2.tar.gz

RUN tar -xvf mydumper-0.6.2.tar.gz

RUN ln -sf /usr/lib/libmysqlclient.so /usr/lib/libmysqlclient_r.so

RUN cd mydumper-0.6.2 && cmake .
RUN cd mydumper-0.6.2 && make
RUN cd mydumper-0.6.2 && make install

RUN ln -sfn /usr/local/bin/mydumper /usr/bin/mydumper

RUN rm -rf s3cmd mydumper-0.6.2 mydumper-0.6.2.tar.gz

RUN echo "innodb_large_prefix=on" >> /etc/mysql/conf.d/mariadb.cnf
RUN echo "innodb_file_format=BARRACUDA" >> /etc/mysql/conf.d/mariadb.cnf
RUN sed -ri "s/max_allowed_packet.*/max_allowed_packet      = 32M/g" /etc/mysql/my.cnf
RUN sed -ri "s/.*general_log             =.*/general_log             = 1/g" /etc/mysql/my.cnf
RUN sed -ri "s~.*general_log_file        =.*~general_log_file        = /tmp/mysql/mysql_general.log~g" /etc/mysql/my.cnf

RUN userdel -r www-data \
        && groupmod -g 33 mysql \
        && usermod -u 33 -g 33 mysql \
        && chown mysql:root /var/run/mysqld

RUN mkdir -p /tmp/mysql && chown mysql:mysql /tmp/mysql

EXPOSE 3306

