FROM python:3.9-bullseye as base

ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1
ENV PIP_DISABLE_PIP_VERSION_CHECK on
ENV PIP_NO_CACHE_DIR off

FROM base as dev

RUN pip install poetry

WORKDIR /wag

COPY poetry.lock ./poetry.lock
COPY pyproject.toml ./pyproject.toml

RUN poetry install

ENTRYPOINT poetry run gunicorn wagtail_demo.wsgi -b 0.0.0.0:5000 \
    --workers 2 \
    --threads 4 \
    --log-file - \
    --capture-output \
    --reload

FROM node:16-alpine as build

WORKDIR /web

COPY ./app/ ./

RUN yarn install --prod

RUN yarn build

FROM base as prod

WORKDIR /backend

COPY ./dev/ ./dev/
COPY ./kvdomingo/ ./kvdomingo/
COPY ./photography/ ./photography/
COPY ./svip/ ./svip/
COPY ./web/ ./web/
COPY ./*.py ./
COPY --from=build /web/build ./app/

EXPOSE $PORT

ENTRYPOINT python manage.py collectstatic --noinput && \
    python manage.py migrate && \
    gunicorn wagtail_demo.wsgi --workers 1 --threads 2 -b 0.0.0.0:$PORT --log-file -
