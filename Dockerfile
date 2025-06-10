FROM python:3.9-slim-buster

# Set environment variables for non-buffered output
ENV PYTHONUNBUFFERED=1

# Install necessary system dependencies for Spark (OpenJDK) and PostgreSQL client libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-17-jdk \
    build-essential \
    python3-dev \
    libpq-dev \
    curl \ # Required to install poetry
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | python -
# Add Poetry to PATH
ENV PATH="/root/.poetry/bin:$PATH"

# Set Dagster Home directory (will be mounted from host)
ENV DAGSTER_HOME=/opt/dagster/dagster_home
RUN mkdir -p $DAGSTER_HOME

# Copy pyproject.toml and poetry.lock first to leverage Docker layer caching
# Assuming pyproject.toml and poetry.lock are in the dagster_code directory
WORKDIR /opt/dagster/app
COPY ./dagster_code/pyproject.toml ./
# If you use poetry.lock for exact dependency pinning, uncomment the line below:
# COPY ./dagster_code/poetry.lock ./

# Install dependencies using Poetry
# --no-root: Don't install the project itself (as we'll copy it later)
# --no-dev: Don't install development dependencies
RUN poetry install --no-root --no-dev

# Copy your Dagster Python code into the container
# This copies the entire directory, including your Python files
COPY ./dagster_code /opt/dagster/app

# Expose the gRPC port for the code server
EXPOSE 4000

# The command to run the code server is defined in docker-compose.yml
