# syntax = docker/dockerfile:1

# Use the official Ruby image as the base image
FROM ruby:3.1

LABEL description="Ankiverse - Sinatra app to help memorising poetry in Anki"

# Set the working directory in the container
WORKDIR /app

# TODO: trim the image with a multistage build like the Rails Dockerfile template

# Copy the Gemfile and Gemfile.lock into the container
COPY Gemfile Gemfile.lock ./

# Install the dependencies
RUN bundle install

# Copy the rest of the application code into the container
COPY . .

# Expose port 80 for the Sinatra app
EXPOSE 80

# Set the command to run the Sinatra app using rackup
CMD rackup --host 0.0.0.0 -p ${PORT:-80}

HEALTHCHECK CMD curl --fail http://localhost:${PORT:-80}/ || exit 1
