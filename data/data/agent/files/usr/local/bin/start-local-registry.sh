#!/usr/bin/env bash

# Mount agendata partition
mkdir -p /mnt/agentdata
mount /dev/disk/by-partlabel/agentdata /mnt/agentdata

# Load registry image
podman load -q -i /mnt/agentdata/images/registry.tar

# Create certificate for the local registry
mkdir -p /mnt/agentdata/certs
cd /mnt/agentdata
openssl req -newkey rsa:4096 -nodes -sha256 -keyout certs/domain.key \
    -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=registry.appliance.com" \
    -addext "subjectAltName=DNS:registry.appliance.com" \
    -x509 -days 36500 -out certs/domain.crt
mkdir -p /etc/docker/certs.d/registry.appliance.com:5000
cp certs/domain.crt /etc/docker/certs.d/registry.appliance.com:5000
mkdir -p /etc/containers/certs.d/registry.appliance.com:5000
cp certs/domain.crt /etc/containers/certs.d/registry.appliance.com:5000
echo "0.0.0.0 registry.appliance.com" >> /etc/hosts
echo "0.0.0.0 api-int.appliance.appliance.com" >> /etc/hosts

# Run local registry image
podman rm registry --force
podman run --privileged -d --name registry -p 5000:5000 \
    -v /mnt/agentdata/registry:/var/lib/registry --restart=always \
    -v /mnt/agentdata/certs:/certs \
    -e REGISTRY_HTTP_ADDR=0.0.0.0:5000 \
    -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
    -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
    docker.io/library/registry:2 

# Install butane
mkdir -p /mnt/sr1
mount /dev/sr1 /mnt/sr1
cp /mnt/sr1/bin/butane /usr/local/bin/
cd /usr/local/bin/
chmod +x butane

# Check how to use ignition.go->getPublicContainerRegistries instead
sed -i 's/PUBLIC_CONTAINER_REGISTRIES=quay.io/PUBLIC_CONTAINER_REGISTRIES=quay.io,registry.appliance.com:5000/g' /usr/local/share/assisted-service/assisted-service.env || true

