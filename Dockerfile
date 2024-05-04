# `python-base` sets up all our shared environment variables
FROM python:3.12.2-slim as python-base

# python
ENV PYTHONUNBUFFERED=1 \
    # prevents python creating .pyc files
    PYTHONDONTWRITEBYTECODE=1 \
    \
    # pip
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    \
    # poetry
    # https://python-poetry.org/docs/configuration/#using-environment-variables
    POETRY_VERSION=1.0.3 \
    # make poetry install to this location
    POETRY_HOME="/opt/poetry" \
    # make poetry create the virtual environment in the project's root
    # it gets named `.venv`
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    # do not ask any interactive question
    POETRY_NO_INTERACTION=1 \
    \
    # paths
    # this is where our requirements + virtual environment will live
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv"

# prepend poetry and venv to path
ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        # deps for installing poetry
        curl \
        # deps for building python deps
        build-essential

# install poetry - respects $POETRY_VERSION & $POETRY_HOME
RUN pip install poetry

RUN apt-get update \
    && apt-get -y install libpq-dev gcc \
    && poetry config virtualenvs.create false

# copy project files
WORKDIR /opt/pysetup
COPY poetry.lock pyproject.toml /opt/pysetup/

# install dependencies
RUN poetry install

WORKDIR /app
COPY . /app/

EXPOSE 8000

# Comando para ativar o ambiente virtual e iniciar o servidor Django
CMD ["/bin/bash", "-c", "source /opt/pysetup/.venv/bin/activate && python manage.py runserver localhost:8000/bookstore/v1/product/"]
