FROM ubuntu:trusty
MAINTAINER hfeng <hfent@tutum.co>

RUN DEBIAN_FRONTEND=noninteractive apt-get -y update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install pptpd
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install vim



#config IPV4 forwarding
RUN echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
RUN echo "net.ipv4.conf.default.rp_filter=1" >> /etc/sysctl.conf
RUN echo "net.ipv4.conf.all.rp_filter=1" >> /etc/sysctl.conf
RUN echo "net.ipv6.conf.all.forwarding=1" >> /etc/sysctl.conf

RUN sysctl -p

#RUN mkdir /var/run/sshd
RUN echo 'root:password!' | chpasswd
#RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
#RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN echo "deb http://archive.ubuntu.com/ubuntu trusty multiverse" >> /etc/apt/sources.list
RUN echo "deb http://archive.ubuntu.com/ubuntu trusty-updates multiverse" >> /etc/apt/sources.list

# 先更新apt-get
RUN apt-get update && apt-get upgrade -y

# 安装unrar
RUN apt-get install unrar -y
RUN apt-get install p7zip-full p7zip-rar -y
#RUN apt-get install p7zip-rar -y

# 安装PHP和Apache
RUN apt-get install apache2 -y
RUN apt-get install php5 libapache2-mod-php5 php5-mcrypt php5-cli php5-curl php5-gd -y


# 安装WebApp
RUN rm -Rf /var/www/html

RUN apt-get install git -y
RUN git clone https://github.com/easychen/KODExplorer.git  /var/www/html


# 安装aria2
RUN apt-get install aria2 -y 

#RUN mkdir cldata
ADD aria2.conf /cldata/aria2.conf
COPY init.sh /cldata/init.sh
COPY init.php /cldata/init.php
RUN chmod +x /cldata/init.sh

#WORKDIR /var/www/html/comic
#RUN mkdir  /var/www/html/comic


ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
EXPOSE 1723
EXPOSE 22
EXPOSE 80 6800
CMD ["/usr/sbin/sshd", "-D"]
