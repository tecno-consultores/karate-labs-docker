# karate-labs-docker
Karate Labs Docker image optimized for CI/CD pipelines (Ephemeral Job).

This container is designed to execute Karate API tests automatically upon startup and exit immediately, returning a success (0) or failure (1) exit code. It is pre-warmed with Maven dependencies for instant execution.

## Build from source code:

```bash
docker build -t karatelabs .
```

## Run with Docker CLI:

To run your tests and extract the HTML reports, use volume mounts. The container will run the tests and stop automatically, cleaning up after itself (`--rm`).

```bash
# 1. Create directories for tests and reports
mkdir -p test reports

# 2. Copy your tests to the input folder
cp -f /home/example/develop/*.feature ./test/

# 3. Run the container (Tests will execute automatically)
docker run --rm \
  -v $(pwd)/test:/app/src/test/java/examples/test \
  -v $(pwd)/reports:/app/target/karate-reports \
  karatelabs
```

## Run with Docker Compose:

The `docker-compose.yml` is already configured with the correct volume bindings for inputs and outputs.

```bash
# 1. Create directories
mkdir -p test reports

# 2. Copy your tests to the input folder
cp -f /home/example/develop/*.feature ./test/

# 3. Start the tests (Do not use -d, so you can see the Maven logs in real-time)
docker compose up
```

Once the execution finishes, the container will exit automatically. You can find your generated HTML test results inside the local `reports/` folder.

Get this image on:
* https://hub.docker.com/r/sinfallas/karatelabs
