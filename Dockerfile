FROM i386/ubuntu:18.04

# The following fails with ubuntu:devel, and adding ARG DEBIAN_FRONTEND=noninteractive didn't work
RUN apt-get -y update && apt-get install -y \
    curl \
    libx11-dev \
    libxext-dev \
    libc6-dev \
    locales \
    gcc \
    gdb \
    wget

# Set up UTF8 locale
RUN locale-gen "en_US.UTF-8" && dpkg-reconfigure locales
ENV LC_ALL=C.UTF-8
# Set up a nice gdbinit
RUN curl -s -L https://github.com/hugsy/gef/raw/master/scripts/gef.sh | sh

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

# Create an inferno user.
RUN useradd -mrs /bin/bash inferno
RUN chown -R inferno:inferno $INFERNO
USER inferno

CMD ["emu", "-c1"]
