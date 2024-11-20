# karate-labs-docker
Karate Labs Docker image

Build from source code:

```bash
* docker build -t karatelabs .
* docker run -d --name karate karatelabs
* docker exec -it karate bash
```

docker compose:

Copy the .feature files to the test folder and then run the tests using the following commands:

```bash
* docker compose up -d
* docker exec -t karatelabs mvn clean test
```

Get this image on:

* https://hub.docker.com/r/sinfallas/karatelabs
