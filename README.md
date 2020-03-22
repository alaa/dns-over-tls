# DNS-Over-TLS Proxy

## Problem:
We wish to create a DNS proxy which listens locally on `tcp/udp` accept at least
one type of DNS query and forward it to secure TLS/DNS resolver from cloudflare
and return the result to the client.

## Approach:
To accomplish this task I used ruby programming language with `rubydns` library.

`rubydns` provides DNS server using `ASYNC/DNS` which is relatively fast DNS server
and adds the ability to intercept the stream and react on it.

After intercepting the stream, I extract the domain and pass the DNS query to `kdig`
which does the actual encrypted DNS query with cloudflare DNS and returns only the
final A records from the Answer.

The proxy creates 2 listeners with port `53/tcp` `53/udp`

## Docker Build
`./scripts/build`
The build script produces the following docker artifact:
`alaa/dns-over-tls:0.0.1`

## Docker RUN / Test query
`./scripts/run`
`dig @0.0.0.0 +tcp cnn.com` -> DNS-Proxy -> Cloudflare (TLS/DNS) `1.1.1.1`

## Local Desktop Usage
It is possible to use it as main local desktop resolver.
simply stop the systemd resolved service: `systemctl stop systemd-resolved` or
any other service which listens on port `53/tcp and udp` and run the container
using `./scripts/run` and change `/etc/resolv.conf` and make sure to have only
`nameserver 127.0.0.1` in it without any additional options i.e: `search`.
Then we will have fully DNS-over-TLS enabled for the laptop out going requests! yay!

## Sniffing Traffic
We can intercept the local DNS-Proxy query using this:
`sudo tcpdump -i lo port 53 -A`

We can also intercept the outgoing TLS/DNS request to cloudflare using:
```
DEFAULT_GW_INTERFACE=$(ip r | grep default | awk '{print $5}')
TLS_DNS=853
sudo tcpdump -i ${DEFAULT_GW_INTERFACE} port ${TLS_DNS} -A
```
