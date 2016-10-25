FROM centos:7
MAINTAINER "Yanbin" <yabqiu@gmail.com>

USER root

RUN yum update
RUN yum -y install wget
