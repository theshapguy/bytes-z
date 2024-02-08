+++

title = "Mikrotik DDNS IPv6 via Cloudflare"
date = "2034-02-08"
draft = false

[taxonomies]
tags = ["networking", "mikrotik"]
categories = ["Today I Learned", "Networking"]


[extra]
lang = "en"
toc = false

+++

The majority of Mikrotik scripts I came across online utilized an external service to locate my IP address, and then used a Global API key to modify the DNS records on Cloudflare. I was searching for a more secure method to update the Cloudflare DNS record.

Creating an authorization token within the Cloudflare Dashboard with limited credentials allows this script to ensure that your entire Cloudflare account is not compromised even if your key leaks.


```bash
# ** CONFIGURE SECTION **

# IPv6 interface
:local wanif    "ether1"

# Cloudflare section

# Using Access Token Instead of Global API Key
:local key      "access_token"
:local zoneId   "zone_id"
# To Find HostId/Record Id, Need to Call Cloudflare API; See Below
:local hostId   "record_id"

# Domain hostname
:local hostName "shapath.com.np"

# ** END OF CONFIGURE SECTION **

# Get WAN interface IPv6 address
:global ip6wan
:local ip6new [/ipv6 address get [/ipv6 address find interface=$wanif global] address]
:set ip6new [:pick [:tostr $ip6new] 0 [:find [:tostr $ip6new] "/"]]

:if ([:len $ip6new] = 0) do={
  :log error "[Cloudflare DDNS] Could not get IPv6 for interface $wanif"
  :error "[Cloudflare DDNS] Could not get IPv6 for interface $wanif"
}

:if ($ip6new != $ip6wan) do={
    
    :local url    "https://api.cloudflare.com/client/v4/zones/$zoneId/dns_records/$hostId"
    :local header "Authorization: Bearer $key, content-type: application/json"
    :local data   "{\"type\":\"AAAA\",\"name\":\"$hostName\",\"content\":\"$ip6new\",\"ttl\":60,\"proxied\":false}"
    
    # :log info "[Cloudflare DDNS] URL: $url"
    # :log info "[Cloudflare DDNS] HEADER: $header"
    # :log info "[Cloudflare DDNS] DATA: $data"
    :log info "[Cloudflare DDNS] Updating host $hostName address to $ip6new"

    :do {
        
      /tool fetch mode=https http-method=put http-header-field=$header http-data=$data url=$url
      :log info "[Cloudflare DDNS] Updated: $ip6new"
      
    } on-error={ 
        
      :log error "[Cloudflare DDNS] Failed to update"
    };
}
```


#### Where is my Record Id/Host Id?

```bash
curl --request GET \
           --url https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records \
           --header 'Content-Type: application/json' \
           --header 'X-Auth-Email: {cloudflare_email@email.com}' \
           --header 'X-Auth-Key: {global_api_token}'
```

Since this Global API Key is only used once to find the correct record id, it is fine for me.

#### Source
- <https://github.com/dudanov/mikrotik-cloudflare-ddns-scripts/blob/master/cloudflare6ddns>