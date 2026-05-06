# ================================
# Build CV
# ================================
FROM debian:bookworm-slim as cv-builder

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
  && apt-get -q update \
  && apt-get -q install -y --no-install-recommends \
    latexmk \
    lmodern \
    texlive-latex-base \
    texlive-latex-recommended \
    texlive-latex-extra \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-plain-generic \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

ENTRYPOINT ["latexmk"]