FROM python:3.6-alpine AS base
ENV PYROOT /pyroot
ENV PYTHONUSERBASE $PYROOT

WORKDIR /opt/blackcat
COPY src/ ./src
COPY config*.yml ./
# Make an empty config file if one doesn't exist.
RUN touch /opt/blackcat/config.yml

# If config is empty, replace with example config, else remove example config.
RUN if [ ! -s '/opt/blackcat/config.yml' ]; then  mv -f /opt/blackcat/config.example.yml /opt/blackcat/config.yml;\
 else  rm -f /opt/blackcat/config.example.yml; \
fi

FROM base as builder
COPY Pipfile* ./
RUN pip install pipenv
RUN pipenv install
RUN PIP_USER=1 PIP_IGNORE_INSTALLED=1 pipenv install --system --deploy --ignore-pipfile

FROM base
COPY --from=builder $PYROOT/lib $PYROOT/lib

RUN addgroup -S usergroup && adduser -S blackcat -G usergroup
USER blackcat
ENTRYPOINT ["python", "src/main.py"]