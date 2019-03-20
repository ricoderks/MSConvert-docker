FROM i386/debian:stretch-backports

LABEL description="Convert LC/MS or GC/MS RAW vendor files to mzML." \
      maintainer="Rico Derks r.j.e.derks@lumc.nl"

# first create user and group for all the X Window stuff
# required to do this first so we have consistent uid/gid between server and client container
RUN addgroup --system xusers \
  && adduser \
			--home /home/xclient \
			--disabled-password \
			# this is a crude solution to get it working on my computer
                        --uid 36480 \
			--shell /bin/bash \
			--gecos "user for running an xclient application" \
			--ingroup xusers \
			--quiet \
			xclient

# unfortunately we later need to wait on wineserver.
# Thus a small script for waiting is supplied.
USER root
COPY waitonprocess.sh /scripts/
RUN chmod a+rx /scripts/waitonprocess.sh

# we need wget, bzip2, wine from winehq, 
# xvfb to fake X11 for winetricks during installation,
# and winbind because wine complains about missing 
RUN apt-get update && \
    apt-get -y install wget gnupg && \
    echo "deb http://dl.winehq.org/wine-builds/debian/ stretch main" >> \
      /etc/apt/sources.list.d/winehq.list && \
    wget -nc https://dl.winehq.org/wine-builds/winehq.key && \
    apt-key add winehq.key && \
    apt-get update && \
    apt-get -y --install-recommends install \
      bzip2 \
      #winehq-stable=3.0* \
      winehq-stable \
      winbind \
      xvfb \
      cabextract \
      && \
    apt-get -y clean && \
    rm -rf \
      /var/lib/apt/lists/* \
      /usr/share/doc \
      /usr/share/doc-base \
      /usr/share/man \
      /usr/share/locale \
      /usr/share/zoneinfo \
      && \
    wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
      -O /usr/local/bin/winetricks && chmod +x /usr/local/bin/winetricks

ENV WINEARCH win32

# WINE does not like running as root
USER xclient
WORKDIR /home/xclient

# wineserver needs to shut down properly!!! 
ENV WINEDEBUG -all,err+all

RUN winetricks -q win7 \
	&& /scripts/waitonprocess.sh wineserver

RUN xvfb-run winetricks -q vcrun2008 dotnet452 \
	&& /scripts/waitonprocess.sh wineserver

# download ProteoWizard and extract it to C:\pwiz
# https://teamcity.labkey.org/repository/download/bt36/538732:id/pwiz-bin-windows-x86-vc120-release-3_0_11748.tar.bz2
RUN mkdir /home/xclient/.wine/drive_c/pwiz && \
    # wget https://teamcity.labkey.org/repository/download/bt36/538732:id/pwiz-bin-windows-x86-vc120-release-3_0_11748.tar.bz2?guest=1 -qO- | \
    wget https://teamcity.labkey.org/repository/download/bt36/716749:id/pwiz-bin-windows-x86-vc141-release-3_0_19079_b8a4d11b3.tar.bz2?guest=1 -qO- | \
      tar --directory=/home/xclient/.wine/drive_c/pwiz -xj
# put C:\pwiz on the Windows search path
ENV WINEPATH "C:\pwiz"

# Set up working directory and permissions to let user xclient save data
USER root
RUN mkdir /data
RUN chmod 777 /data
RUN chown xclient:xusers /data
RUN chown xclient:xusers /
WORKDIR /data

USER xclient

ENTRYPOINT [ "wine", "/home/xclient/.wine/drive_c/pwiz/msconvert.exe" ]
#ENTRYPOINT [ "/bin/bash", "-c" ]
