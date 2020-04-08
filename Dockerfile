FROM i386/ubuntu:18.04

# The following fails with ubuntu:devel, and adding ARG DEBIAN_FRONTEND=noninteractive didn't work
RUN apt-get -y update && apt-get install -y \
    libx11-dev \
    libxext-dev \
    libc6-dev \
    gcc

# if on i386 there's no need for multilib
#RUN apt-get install -y libc6-dev-i386
#RUN apt-get install -y libx11-6:i386, libxext-dev:i386
#RUN apt-get install -y gcc-multilib

ENV INFERNO=/usr/inferno
COPY . $INFERNO
WORKDIR $INFERNO
# Required for the multiline echo format below
SHELL [ "/bin/bash", "-c"]

# setup a custom mkconfig
RUN echo $'ROOT=/usr/inferno \n\
    TKSTYLE=std \n\
    SYSHOST=Linux \n\
    SYSTARG=Linux \n\
    OBJTYPE=386 \n\
    OBJDIR=$SYSTARG/$OBJTYPE \n\
    <$ROOT/mkfiles/mkhost-$SYSHOST \n\
    <$ROOT/mkfiles/mkfile-$SYSTARG-$OBJTYPE' > mkconfig

# build code
RUN ./makemk.sh
ENV PATH="$INFERNO/Linux/386/bin:${PATH}"
RUN mk nuke
RUN mk install

CMD ["emu", "-c1",  "wm/wm"]
