FROM node:16-buster

RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    cron \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install -i /usr/local/aws-cli -b /usr/local/bin \
    && rm awscliv2.zip \
    && rm -rf aws

# Add SSH credentials
RUN mkdir -p -m 0600 ~/.ssh \
    && ssh-keyscan github.com >> ~/.ssh/known_hosts \
    && chown -R root:root ~/.ssh

# Clone app source
RUN --mount=type=secret,id=ssh_key GIT_SSH_COMMAND="ssh -i /run/secrets/ssh_key" git clone git@github.com:mjhale/blaseball-reference-scripts.git /usr/src/app

# Create app directory
WORKDIR /usr/src/app
RUN chmod +x update-json.sh

# Add cron task for update script
COPY crontab /etc/cron.d/blaseball-cron
RUN crontab /etc/cron.d/blaseball-cron
CMD ["cron", "-f"]
