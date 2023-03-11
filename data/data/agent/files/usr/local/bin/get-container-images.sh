#!/usr/bin/env bash
set -euo pipefail

/usr/local/bin/release-image-download.sh

# shellcheck disable=SC1091
. /usr/local/bin/release-image.sh

# Store images in the environment file used by services and passed to assisted-service
# The agent image will be also retrieved when its script is run
cat <<EOF >/usr/local/share/assisted-service/agent-images.env
#SERVICE_IMAGE=$(image_for agent-installer-api-server)
#AGENT_DOCKER_IMAGE=$(image_for agent-installer-node-agent)
CONTROLLER_IMAGE=$(image_for agent-installer-csr-approver)
INSTALLER_IMAGE=$(image_for agent-installer-orchestrator)
#SERVICE_IMAGE=
#AGENT_DOCKER_IMAGE=
# quay.io/nmagnezi/assisted-service:appliance2
SERVICE_IMAGE=quay.io/nmagnezi/assisted-service@sha256:5bf871a7109b647a5ec6f58d545ad6156bfcc27377a5a66357a7b369ebbe450c
# quay.io/masayag/assisted-installer-agent:billi
AGENT_DOCKER_IMAGE=quay.io/masayag/assisted-installer-agent@sha256:93afd3965abb3b1019d001a096280e4f012843f734e6d5851f0bac743f4ffaa3
EOF
