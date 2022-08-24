# Simple Sliver C2 Docker Container

## Warning

**Disclaimer**: This image is just a quick lazy hack. It is yet to be battle-tested (write me about your experience in the discussions!)! If you do decide to use this container I only take responsibility in your successes and not in your failures or any damages that occur while using this container!

## Description

This is a very simple Docker container based off of [warhorse/docker-sliver](https://github.com/warhorse/docker-sliver) and the build container from [github.com/BishopFox/sliver](https://github.com/BishopFox/sliver/blob/master/Dockerfile).

This container basically automates the recommended installation process without recompiling everything:

1. Install apt dependencies
2. Install Metasploit nightly (following the [official documentation](https://docs.metasploit.com/docs/using-metasploit/getting-started/nightly-installers.html))
3. Install sliver with code ripped from the [official Linux install script](https://github.com/BishopFox/sliver/wiki/Linux-Install-Script)

I've also attached a docker compose file for even quicker and lazier deployments!

The sliver applications run as uid 10000 within the container. So make sure that any volumes that you want to mount are also accessible by the sliver user within the container (chown'ed or chmod'ed on the outside!)

## Usage

Build the image:

```sh
git clone $REPO_URL
cd container-sliver
docker build -t sliver .
```

Run sliver as daemon (with multiplayer port):

```sh
docker run --name sliver_server -p 80:80 -p 443:443 -p 31337:31337 --security-opt="no-new-privileges:true" --cap-drop=ALL --cap-add=SETFCAP --cap-add=NET_BIND_SERVICE --cap-add=NET_RAW -d sliver daemon
```

Run sliver as daemon; attach volumes for different files:
```sh
docker run --name sliver_server -p 80:80 -p 443:443 -p 31337:31337 \
 -v $(pwd)/configs:/configs \
 -v $(pwd)/phishlets:/phishlets \
 -v $(pwd)/payloads:/payloads \
 -v $(pwd)/misc:/misc \
 --cap-drop=ALL \
 --cap-add=SETFCAP \
 --cap-add=NET_BIND_SERVICE \
 --cap-add=NET_RAW
 --security-opt="no-new-privileges:true" \
 -d sliver daemon
```

Connect with a client in an already running container:
```sh
docker exec -it sliver_server sliver
```

Run a temporary server without additional security measures interactively:
```sh
docker run --rm -p 80:80 -p 443:443 -it sliver
```

## FAQ

- Why?
  - Yes
- What is this gigantic block of base64 in the middle of your dockerfile?
  - Super short explanation: [Click Here](https://gchq.github.io/CyberChef/#recipe=From_Base64('A-Za-z0-9%2B/%3D',true,false)Generic_Code_Beautify()&input=Wm05eUlGVlNUQ0JwYmlBa0tHTjFjbXdnTFhNZ0ltaDBkSEJ6T2k4dllYQnBMbWRwZEdoMVlpNWpiMjB2Y21Wd2IzTXZRbWx6YUc5d1JtOTRMM05zYVhabGNpOXlaV3hsWVhObGN5OXNZWFJsYzNRaUlId2dZWGRySUMxR0lDY2lKeUFuTDJKeWIzZHpaWEpmWkc5M2JteHZZV1JmZFhKc0wzdHdjbWx1ZENBa05IMG5LVHNnWkc4Z2FXWWdXMXNnSWlSVlVrd2lJRDA5SUNvaWMyeHBkbVZ5TFhObGNuWmxjbDlzYVc1MWVDSXFJRjFkT3lCMGFHVnVJR1ZqYUc4Z0lrUnZkMjVzYjJGa2FXNW5JQ1JWVWt3aU8yTjFjbXdnTFMxemFXeGxiblFnTFV3Z0pGVlNUQ0F0TFc5MWRIQjFkQ0FrS0dKaGMyVnVZVzFsSUNSVlVrd3BPMlpwTzJsbUlGdGJJQ0lrVlZKTUlpQTlQU0FxSW5Oc2FYWmxjaTFqYkdsbGJuUmZiR2x1ZFhnaUtpQmRYVHNnZEdobGJpQmxZMmh2SUNKRWIzZHViRzloWkdsdVp5QWtWVkpNSWp0amRYSnNJQzB0YzJsc1pXNTBJQzFNSUNSVlVrd2dMUzF2ZFhSd2RYUWdKQ2hpWVhObGJtRnRaU0FrVlZKTUtUdG1hVHRrYjI1bA)
  - Short explanation: A lot of bashisms that bash (see what I did there?) with the docker RUN instruction [since it runs commands with /bin/sh -c](https://docs.docker.com/engine/reference/builder/#run). The commands are directly ~~ripped~~ leveraged from lines 102-117 from [the official install script](https://github.com/BishopFox/sliver/blob/29755d71094ec100d5f19e580ee97167e2869fa7/docs/install#L102)
  
## TODOs

- Find out why generating a new implant can sometimes end in a rpc error?
- Write commands (or build instructions) for server and operator configurations
- MiniJail profile ;-;
- Add questions to FAQ if there are any
- Add more TODOs
