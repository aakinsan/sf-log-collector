# Use the official lightweight Python image.
# https://hub.docker.com/_/python
FROM python:3.10.12-slim

# Allow statements and log messages to immediately appear in the logs
ENV PYTHONUNBUFFERED True

# Define a work directory
WORKDIR /app

# Copy dependencies file into working directory
COPY ./sfatc/requirements.txt /app

# Install production dependencies.
RUN pip install --no-cache-dir -r requirements.txt

# Copy helper function code to the container image.
COPY utils/ /app/utils/

# Copy local code to the container image.
COPY ./sfatc/. /app

# Run the web service on container startup.
CMD [ "python", "./sfatc.py" ]