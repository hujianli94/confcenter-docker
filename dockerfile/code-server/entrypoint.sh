sudo chown coder /home/coder
sudo chown coder /home/coder/workspace
dumb-init fixuid -q code-server --bind-addr 0.0.0.0:8080 --disable-telemetry --disable-update-check --disable-file-downloads .

