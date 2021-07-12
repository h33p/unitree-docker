# Unofficial Docker container for Unitree Robotics ROS setup

## Build

```
podman build -t unitree-docker .
```

### Run with GUI

```
podman run --name unitree-container -e DISPLAY=unix$DISPLAY --ipc host -v /tmp/.X11-unix:/tmp/.X11-unix -v ~/.Xauthority:/root/.Xauthority:Z -it unitree-docker
```

### Run with GUI and AMD GPU

Extract AMDGPU-Pro drivers to `/opt/amdgpu-pro-bundle/`, and run `./run_amdgpupro.sh`

## Open additional shells

```
podman exec -it unitree-container /entrypoint.bash bash
```
