FROM python:3.6.0-alpine

WORKDIR /app
ADD . /app

RUN apk update && apk add --no-cache musl-dev gcc && \
    pip install --upgrade pip && \
    pip install -r /app/requirements.txt && \
    apk del gcc musl-dev && \
    rm -rf /var/cache/apk/*

ENV POST_DATABASE_HOST post_db
ENV POST_DATABASE posts

CMD ["python3","post_app.py"]
