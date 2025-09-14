+++

title = "Self-Hosted Tailscale DERP Server"
date = "2025-09-14"
draft = false

[taxonomies]
tags = ["tailscale", "docker", "networking", "derp"]
categories = ["Today I Learned", "Networking"]


[extra]
lang = "en"
toc = false

+++

Setting up a custom DERP (Designated Encrypted Relay for Packets) server for Tailscale allows you to route traffic through your own infrastructure when direct peer-to-peer connections aren't possible.

## Why Self-Host?

Tailscale's default DERP servers can be quite slow and their QoS (Quality of Service) severely impacts performance for long-term streaming use cases. While they work perfectly fine for one-time use cases like quick file transfers or occasional remote access, sustained traffic like video streaming or large file synchronization suffers from bandwidth limitations and throttling.

**Self-hosting your own DERP server eliminates these performance bottlenecks and gives you full control over the relay infrastructure. It's not a dramatic speedboot you're going to see, but it's quite a bit faster for sustained workloads.**

## Running the DERP Server

Deploy the DERP server using Docker with client verification enabled:

```bash
sudo docker run -d \
  --name derper \
  --restart unless-stopped \
  -e DERP_DOMAIN=derper.domain.com.np \
  -e DERP_VERIFY_CLIENTS=true \
  -v /var/run/tailscale/tailscaled.sock:/var/run/tailscale/tailscaled.sock \
  -p 8480:80 \
  -p 8443:443 \
  -p 3478:3478/udp \
  fredliang/derper
```

The `DERP_VERIFY_CLIENTS=true` flag ensures only your Tailscale clients can connect, authenticating through the mounted Unix socket.

## Configuring Custom DERP Region

Add your custom DERP server to Tailscale's ACL configuration in the Tailscale dashboard using a region ID between 900-999:

```json
	"derpMap": {
		"OmitDefaultRegions": false,
		"Regions": {
			"901": {
				"RegionID":   901,
				"RegionCode": "selfhosted-derp",
				"regionName": "AsiaPacific",
				"Nodes": [
					{
						"Name":     "1",
						"RegionID": 901,
						"HostName": "derper.domain.com",
						"STUNPort": 3478,
						"DERPPort": 443,
					},
				],
			},
		},
	}
```

## Reverse Proxy for SSL Certificates

Use Caddy to handle SSL certificate issuance and reverse proxy to the DERP server:

```caddyfile
http://derper.domain.com {
    reverse_proxy localhost:8480
}
```

This configuration allows Let's Encrypt to issue certificates from within the Docker container through the reverse proxy setup.

## Key Benefits

- **Custom routing**: Control where your Tailscale traffic is relayed
- **Reduced latency**: Place DERP servers closer to your devices
- **Enhanced privacy**: Keep relay traffic on your own infrastructure
- **Client verification**: Only authenticated Tailscale clients can use the relay
