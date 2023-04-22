FROM debian:11

ARG KUBERNETES_VERSION

RUN apt-get update && apt-get -y install curl unzip && apt-get clean
RUN curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip && unzip awscliv2.zip && rm awscliv2.zip && ./aws/install
ADD create_sa.sh /
RUN chmod 755 create_sa.sh

ENTRYPOINT ["/create_sa.sh"]
