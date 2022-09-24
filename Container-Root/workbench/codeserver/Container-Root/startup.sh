#!/bin/sh

# Container startup script
echo "Container-Root/startup.sh executed"

echo ""
cat /startup/workbench.txt
echo ""

/usr/lib/code-server/lib/node /usr/lib/code-server --bind-addr 0.0.0.0:8080 --disable-telemetry --auth none

