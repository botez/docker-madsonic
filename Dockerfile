FROM phusion/baseimage:0.9.11
MAINTAINER botez <troyolson1@gmail.com>
ENV DEBIAN_FRONTEND noninteractive

# Set correct environment variables
ENV HOME /root

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

# Fix a Debianism of the nobody's uid being 65534
RUN usermod -u 99 nobody
RUN usermod -g 100 nobody

RUN apt-get update -q

# install dependencies for madsonic
RUN apt-get install -qy openjdk-7-jre
RUN apt-get clean

# install madsonic
ADD http://madsonic.org/download/5.1/20140322_madsonic-5.1.4046.beta1.deb /tmp/madsonic.deb
RUN dpkg -i /tmp/madsonic.deb && rm /tmp/madsonic.deb

# Create hardlinks to the transcoding binaries.
# This way we can mount a volume over /var/subsonic.
# Apparently, Subsonic does not accept paths in the Transcoding settings.
# If you mount a volume over /var/subsonic, create symlinks
# <host-dir>/var/subsonic/transcode/ffmpeg -> /usr/local/bin/ffmpeg
# <host-dir>/var/subsonic/transcode/lame -> /usr/local/bin/lame
RUN ln /var/madsonic/transcode/ffmpeg /var/madsonic/transcode/lame /usr/local/bin
RUN chown -R nobody:users /var/madsonic

EXPOSE 4040
EXPOSE 4050


VOLUME /config

# Add Madsonic to runit
RUN mkdir /etc/service/madsonic
ADD madsonic.sh /etc/service/madsonic/run
RUN chmod +x /etc/service/madsonic/run

