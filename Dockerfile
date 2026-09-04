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

WORKDIR /build

COPY resume/cv.tex resume/styling.sty ./

RUN  mkdir -p .output \
  && latexmk -pdf -interaction=nonstopmode -outdir=.output -jobname=mobile-resume \
       -pdflatex='pdflatex %O "\def\showmobile{}\input{%S}"' cv.tex \
  && latexmk -pdf -interaction=nonstopmode -outdir=.output -jobname=web-resume \
       -pdflatex='pdflatex %O "\def\showweb{}\input{%S}"' cv.tex \
  && latexmk -pdf -interaction=nonstopmode -outdir=.output -jobname=swift-resume \
       -pdflatex='pdflatex %O "\def\showswift{}\input{%S}"' cv.tex \
  && latexmk -pdf -interaction=nonstopmode -outdir=.output -jobname=resume \
       -pdflatex='pdflatex %O "\def\showmobile{}\def\showweb{}\input{%S}"' cv.tex \
  && rm -f .output/*.aux .output/*.log .output/*.out .output/*.fdb_latexmk .output/*.fls

# ================================
# Base swift build
# ================================
FROM swift:6.3-bookworm AS builder

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get install -y libjemalloc-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

COPY ./Package.* ./
RUN swift package resolve \
        $([ -f ./Package.resolved ] && echo "--force-resolved-versions" || true)

COPY . .

RUN swift build -c release \
        --static-swift-stdlib \
        -Xlinker -ljemalloc

RUN BIN_PATH="$(swift build -c release --show-bin-path)" \
    && mkdir -p /staging/site-server /staging/ssh-server \
    && cp "$BIN_PATH/SiteServer" /staging/site-server/ \
    && cp "$BIN_PATH/SiteSSHServer" /staging/ssh-server/ \
    && find -L "$BIN_PATH" -regex '.*SiteServer.*\.resources$' -exec cp -Ra {} /staging/site-server/ \; \
    && find -L "$BIN_PATH" -regex '.*SiteSSHServer.*\.resources$' -exec cp -Ra {} /staging/ssh-server/ \;

# ================================
# Run site-server
# ================================
FROM debian:bookworm-slim AS site-server

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get -q install -y \
    libjemalloc2 \
    ca-certificates \
    tzdata \
    libcurl4 \
    && rm -r /var/lib/apt/lists/*

RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /server deploy

WORKDIR /server

COPY --from=builder --chown=deploy:deploy /staging/site-server /server

COPY --from=builder --chown=deploy:deploy /build/public ./public
COPY --from=cv-builder --chown=deploy:deploy /build/.output ./public

ENV SWIFT_BACKTRACE=enable=yes,sanitize=yes,threads=all,images=all,interactive=no,swift-backtrace=./swift-backtrace-static

USER deploy:deploy

EXPOSE 8080

ENTRYPOINT ["./SiteServer"]
CMD ["--hostname", "0.0.0.0", "--port", "8080"]

# ================================
# Run site-ssh-server 
# ================================
FROM debian:bookworm-slim AS ssh-server

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get -q install -y \
    libjemalloc2 \
    ca-certificates \
    tzdata \
    libcurl4 \
    && rm -r /var/lib/apt/lists/*

RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /server deploy

WORKDIR /server

COPY --from=builder --chown=deploy:deploy /staging/ssh-server /server

ENV SWIFT_BACKTRACE=enable=yes,sanitize=yes,threads=all,images=all,interactive=no,swift-backtrace=./swift-backtrace-static

USER deploy:deploy

EXPOSE 2222

ENTRYPOINT ["./SiteSSHServer"]
CMD ["--hostname", "0.0.0.0", "--port", "2222"]
