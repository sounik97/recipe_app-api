FROM python:3.9-alpine3.13

LABEL maintainer = "dronzer"
# tells python don't buffer the output, directly paste the logs in the screen
ENV PYTHONUNBUFFERED 1

# This block copies the requiremnt file and app to a location
# workdir is default directory where the app will run from
COPY ./requirements.txt /tmp/requirements.txt 
COPY ./requirements.dev.txt /tmp/requirements.dev.txt 
COPY ./app /app
WORKDIR /app
EXPOSE 8000

# This block runs a series of command into alpine image that we've chosen at line first 
# we added extra user to use the the app through that user and not root user because root user has all the access
# by default the dev is false, but we have setup in docker-compose an arg as dev=true, if arg is passed it will run only on dev
ARG DEV=false
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    # this is a shell script, if dev is true the we'll install the dev requirements.dev.txt else dont install
    if [ $DEV = "true" ] ; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# This updates the update the Path under the Docket Image
ENV PATH="/py/bin:$PATH"

# this line is changing user to django-user at the last stage, so after running this Dockerfile we'll be able to access via 
# django-user only, not root user
USER django-user