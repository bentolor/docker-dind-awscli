ARG DOCKER_VER=29
FROM docker:${DOCKER_VER}

ARG AWS_CLI_VER=2.31.33

# 2025-11: Switch to native alpine APK
RUN apk --update-cache add \
        groff \
        bash \
        less \
        aws-cli \
    && sed -i 's/ash/bash/g' /etc/passwd \
    && docker --version \
    && aws --version

CMD ["/bin/bash"]
