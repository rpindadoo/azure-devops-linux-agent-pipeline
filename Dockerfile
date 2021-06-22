FROM ubuntu:16.04

# To make it easier for build and release pipelines to run apt-get,
# configure apt to not require confirmation (assume the -y argument by default)
ENV DEBIAN_FRONTEND=noninteractive
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes


ENV IMAGE_VERSION=dev \
    METADATA_FILE=/scripts/metadatafile.log \
    HELPER_SCRIPTS=/scripts/helpers

RUN apt-get update \
  && apt-get dist-upgrade -y \
  && systemctl disable apt-daily.service \
  && systemctl disable apt-daily.timer \
  && systemctl disable apt-daily-upgrade.timer \
  && systemctl disable apt-daily-upgrade.service \
  && echo '* soft nofile 50000 \n* hard nofile 50000' >> /etc/security/limits.conf \
  && echo 'session required pam_limits.so' >> /etc/pam.d/common-session \
  && echo 'session required pam_limits.so' >> /etc/pam.d/common-session-noninteractive

RUN apt-get update
RUN apt-get install apt-utils -y
RUN apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        curl \
        file \
        ftp \
        jq \
        gnupg \
        iputils-ping \
        libcurl3 \
        libicu55 \
        libunwind8 \
        locales \
        lsb-release \
        netcat \
        rsync \
        software-properties-common \
        sudo \
        time \
        unzip \
        wget \
        zip


RUN apt-get update; \
    apt-get install software-properties-common

RUN  apt-get update \
  && apt-get install -y wget \
  && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
 && apt-get install -y sudo \
 tzdata 

#install git newest version
RUN add-apt-repository ppa:git-core/ppa; \
    apt-get update; \
    apt-get upgrade; \
    apt-get install git -y




RUN apt-get update; \
    apt-add-repository https://packages.microsoft.com/ubuntu/16.04/prod



RUN curl -LsS https://aka.ms/InstallAzureCLIDeb | bash \
  && rm -rf /var/lib/apt/lists/*



#.NET RUNTIME 2.1 AND SDK 5.0
RUN apt-get update; \
    apt-get install -y apt-transport-https && \
    apt-get update && \
    apt-get install -y dotnet-runtime-2.1

RUN apt-get update; \
    apt-get install -y apt-transport-https && \
    apt-get update && \
    apt-get install -y dotnet-sdk-5.0



#POWERSHELL
RUN dotnet tool install -g powershell    


#INSTALL CHROME AND CHROMEDRIVER
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && apt-get install ./google-chrome-stable_current_amd64.deb
RUN wget https://chromedriver.storage.googleapis.com/2.41/chromedriver_linux64.zip; \
    unzip chromedriver_linux64.zip; \
    mv chromedriver /usr/bin/chromedriver; \
    chown root:root /usr/bin/chromedriver; \
    chmod +x /usr/bin/chromedriver; \
    wget https://selenium-release.storage.googleapis.com/3.13/selenium-server-standalone-3.13.0.jar; \
    wget http://www.java2s.com/Code/JarDownload/testng/testng-6.8.7.jar.zip; \
    unzip testng-6.8.7.jar.zip



ARG TARGETARCH=amd64
ARG AGENT_VERSION=2.185.1

WORKDIR /azp
RUN if [ "$TARGETARCH" = "amd64" ]; then \
      AZP_AGENTPACKAGE_URL=https://vstsagentpackage.azureedge.net/agent/${AGENT_VERSION}/vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz; \
    else \
      AZP_AGENTPACKAGE_URL=https://vstsagentpackage.azureedge.net/agent/${AGENT_VERSION}/vsts-agent-linux-${TARGETARCH}-${AGENT_VERSION}.tar.gz; \
    fi; \
    curl -LsS "$AZP_AGENTPACKAGE_URL" | tar -xz

#INSTALL JDK 
RUN sudo add-apt-repository -y ppa:openjdk-r/ppa
RUN apt-get update && \
    apt-get install -yq openjdk-11-jdk 

RUN java -version


COPY ./start.sh .
RUN chmod +x start.sh

ENTRYPOINT [ "./start.sh" ]