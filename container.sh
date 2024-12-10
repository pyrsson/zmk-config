if podman container exists zmk-build; then
  podman start zmk-build
  podman attach zmk-build
  podman stop zmk-build
else
  podman run -it \
    --security-opt label=disable \
    --workdir /workspaces/zmk \
    -v ../zmk:/workspaces/zmk \
    -v "$PWD":/workspaces/zmk-config \
    -p 3000:3000 \
    --name zmk-build \
    zmk-build /bin/bash
  podman stop zmk-build
fi
