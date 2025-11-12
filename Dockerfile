ARG DOCKER_VER=29.0.0
FROM docker:${DOCKER_VER}

ARG AWS_CLI_VER=2.31.33

# 2025-11: Download and locally build awscli v2 now with MUSL glibc support
#          instead former approach of installing glibc
RUN apk --update-cache add \
        groff \
        bash \
        git \
        unzip \
        build-base \
        libffi-dev \
        cmake \
        python3 \
    && sed -i 's/ash/bash/g' /etc/passwd \
    && echo "git clone --single-branch --depth 1 -b ${AWS_CLI_VER} https://github.com/aws/aws-cli.git" \
    && git clone --single-branch --depth 1 -b ${AWS_CLI_VER} https://github.com/aws/aws-cli.git \
    && cd aws-cli \
    && ./configure --with-install-type=portable-exe --with-download-deps \
    && make \
    && make install \
    && cd / \
    && rm -rf \
        aws-cli \
        /usr/local/aws-cli/v2/*/dist/aws_completer \
        /usr/local/aws-cli/v2/*/dist/awscli/data/ac.index \
        /usr/local/aws-cli/v2/*/dist/awscli/examples \
    && rm -rf /var/cache/apk/* \
    && docker --version \
    && aws --version

CMD ["/bin/bash"]
