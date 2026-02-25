FROM node:22-bookworm

# Create non-root user
RUN useradd -ms /bin/bash dev
USER dev

# Create dev user with passwordless sudo
RUN useradd -m -s /bin/bash dev \
  && echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/dev \
  && chmod 0440 /etc/sudoers.d/dev

RUN apt-get update && apt-get install -y \
    sudo net-tools iputils-ping mtr curl wget jq ca-certificates htop mlocate \
    git git-lfs \
    openvpn tor \
    software-properties-common \    
    # python3.12 python3.12-venv python3.12-dev \
  && rm -rf /var/lib/apt/lists/*

# Switch to dev user
USER dev

RUN corepack enable \
  && corepack prepare yarn@stable --activate \
  && corepack prepare pnpm@latest --activate

RUN npm install -g @anthropic-ai/claude-code

RUN curl -sSL https://github.com/coder/agentapi/releases/latest/download/agentapi-linux-x64 \
    -o /usr/local/bin/agentapi \
  && chmod +x /usr/local/bin/agentapi

RUN git config --global user.email "nyam@ny.am" \
  && git config --global user.name "nyam" \
  && git config --global pull.rebase false

RUN echo 'export TERM=xterm-256color' >> /home/dev/.bashrc \
  &&  echo 'alias ll="ls -alF"' >> /home/dev/.bashrc 
  # These for reference only, won't work since dockerfile is direct exec (no ENVs)
  # && echo 'alias claude-agent="agentapi server --port 8080 --allowed-origins 'localhost,127.0.0.1,192.168.3.99' -- claude"' >> /home/dev/.bashrc \
  # && echo 'alias claude-agent-wideopen="agentapi server --port 8080 --allowed-origins \"*\" -- claude"' >> /home/dev/.bashrc

# # Install pip for Python 3.12
# RUN curl https://bootstrap.pypa.io/get-pip.py | python3.12

# # Set Python 3.12 as default
# RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1 \
#   && update-alternatives --install /usr/bin/python python /usr/bin/python3.12 1 \
#   && update-alternatives --install /usr/bin/pip pip /usr/bin/pip3.12 1

WORKDIR /code

ENV CLAUDE_DISABLE_TELEMETRY=1 \
  ANTHROPIC_BASE_URL=https://api.z.ai/api/anthropic \
  ANTHROPIC_DEFAULT_HAIKU_MODEL=glm-4.5-air \
  ANTHROPIC_DEFAULT_OPUS_MODEL=glm-4.7 \
  ANTHROPIC_DEFAULT_SONNET_MODEL=glm-4.7 \
  API_TIMEOUT_MS=3000000

CMD ["bash"]
