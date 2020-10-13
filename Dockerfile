######################
# INSTALLATION STAGE #
######################
FROM ubuntu:18.04 as builder

ARG USER=was
ARG GROUP=was

COPY source /work/source
COPY update /work/update
COPY responsefile /work/responsefile

RUN groupadd $GROUP \
  && useradd $USER -g $GROUP -m \
  && chown -R $USER:$GROUP /work /opt

USER $USER

RUN echo "📦 Unarchiving WebSphere Application Server 7.0 installation package..." \
  && mkdir -p /work/was \
  && tar -xzf /work/source/was.7000.wasdev.nocharge.linux.amd64.tar.gz -C /work/was/ \
  && echo "☑ Done."

RUN echo "📥 Installing WebSphere Application Server 7.0..." \
  && /work/was/WAS/install -options /work/responsefile/responsefile.text -silent \
  && echo "☑ Done."

RUN echo "📦 Unarchiving WebSphere Application Server 7.0 Update Installer intallation package..." \
  && mkdir -p /work/updi \
  && tar -xzf /work/source/7.0.0.*-WS-UPDI-LinuxAMD64.tar.gz -C /work/updi/ \
  && echo "☑ Done."

RUN echo "📥 Installing WebSphere Application Server 7.0 Update Installer..." \
  && /work/updi/UpdateInstaller/install -options /work/responsefile/responsefile.updateinstaller.text -silent \
  && echo "☑ Done."

RUN echo "📥 Installing WebSphere Application Server 7.0 Updates..." \
  && /opt/IBM/WebSphere/UpdateInstaller/update.sh -options /work/responsefile/responsefile.update.text -silent \
  && echo "☑ Done."


##########################
# PROFILE CREATION STAGE #
##########################
FROM ubuntu:18.04

LABEL maintainer="Pei-Tang Huang <beta@cht.com.tw>"

ARG USER=was
ARG GROUP=was

ARG PROFILE_NAME=AppSrv01
ARG CELL_NAME=DefaultCell01
ARG NODE_NAME=DefaultNode01
ARG HOST_NAME=localhost
ARG SERVER_NAME=server1

ENV PROFILE_NAME=$PROFILE_NAME \
  SERVER_NAME=$SERVER_NAME \
  ADMIN_USER_NAME=$ADMIN_USER_NAME

COPY --from=builder /opt /opt
COPY script /work/script

# !!! IMPORTANT !!!
# change Ubuntu's default shell interpreter from `dash` to `bash`
# otherwise the wsadmin.sh will not run properly
RUN yes n | dpkg-reconfigure dash > /dev/null 2>&1

RUN groupadd $GROUP \
  && useradd $USER -g $GROUP -m \
  && chown -R $USER:$GROUP /work /opt

USER $USER

# mark createProfileShortCut2StartMenuDefault optional
RUN sed -i 's#<action path="actions/createProfileShortCut2StartMenuDefault.ant" priority="93" isFatal="false">#<action path="actions/createProfileShortCut2StartMenuDefault.ant" priority="93" isFatal="false" isOptional="true">#' \
  /opt/IBM/WebSphere/AppServer/profileTemplates/default/actionRegistry.xml

# create profile
RUN /work/script/create_profile.sh

ENV PATH /opt/IBM/WebSphere/AppServer/bin:$PATH

# exposing SOAP connector port (8880), administrative console port (9060), HTTP transport port (9080)
EXPOSE 8880 9060 9080

CMD ["/work/script/start_server.sh"]
