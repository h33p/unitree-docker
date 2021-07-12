#!/bin/sh

podman run --name unitree-container -e DISPLAY=unix$DISPLAY --ipc host -v /tmp/.X11-unix:/tmp/.X11-unix -v ~/.Xauthority:/root/.Xauthority:Z -e dri_driver="amdgpu" -e LIBGL_DRIVERS_PATH="/opt/amdgpu-pro-bundle/usr/lib/x86_64-linux-gnu/dri/" -e LD_LIBRARY_PATH="/opt/amdgpu-pro-bundle/opt/amdgpu-pro/lib/x86_64-linux-gnu" -v /opt/amdgpu-pro-bundle:/opt/amdgpu-pro-bundle $@ -it unitree-docker
