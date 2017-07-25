FROM ubuntu:17.04

# Make a non-root version for security reasons.
# The default user is root when entering a Docker container. By creating a
# non-root user, and then switching to the non-root user mitigates root attacks
# inside the server.
RUN useradd -r user

USER root
RUN apt update -y && apt install -y \
    unzip \
# Stuff for GLPK
    wget \
    build-essential \
# Python
    python3-setuptools \
    python3-wheel \
    python3.6 \
    python3-pip \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /user/local/
RUN wget http://ftp.gnu.org/gnu/glpk/glpk-4.61.tar.gz \
    && tar -zxvf glpk-4.61.tar.gz

WORKDIR /user/local/glpk-4.61
RUN ./configure \
    && make \
    && make check \
    && make install \
    && make distclean \
    && ldconfig \
    && rm -rf /user/local/glpk-4.61.tar.gz \
    && apt clean

WORKDIR /pyhub

# Put the energy hub code directly into image
RUN wget https://github.com/hues-platform/python-ehub/archive/dev.zip \
    && unzip dev.zip \
    && mv python-ehub-dev/* . \
    && rm -r python-ehub-dev \
    && python3.6 -m pip install -r requirements.txt

ADD . /pyhub

RUN python3.6 -m pip install -r server_requirements.txt

RUN chown user /pyhub

USER user
EXPOSE 8080

CMD ["python3.6", "server.py"]
