#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with google_auth_proxy](#setup)
    * [What google_auth_proxy affects](#what-google_auth_proxy-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with google_auth_proxy](#beginning-with-google_auth_proxy)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
    * [Classes and Defined Types](#classes-and-defined-types)
        * [Defined Type: google_auth_proxy](#defined-type-google_auth_proxy)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

The google_auth_proxy module allows you to set up and manage instances of the [bitly Google OAuth2 proxy](https://github.com/bitly/google_auth_proxy) with minimal effort.

## Module Description

[google_auth_proxy](https://github.com/bitly/google_auth_proxy) is an HTTP Reverse Proxy that provides authentication using [Google’s OAuth2 API](https://developers.google.com/accounts/docs/OAuth2) with flexibility to authorize individual Google Accounts (by email address) or a whole Google apps domain. Read more about it in [this blog post](http://word.bitly.com/post/47548678256/google-auth-proxy) and see detailed instructions on [github](https://github.com/bitly/google_auth_proxy).

This module makes it easy to deploy a proxy for an existing application.

This module was developed for, and only tested on, CentOS 7.

It was also developed for use in an AWS environment with SSL termination at the ELB, ie. there is no provision to set up `https` proxies. I may add this at some stage in the future. PRs welcome. :)

## Architecture

Taken from the google_auth_proxy [README](https://github.com/bitly/google_auth_proxy/blob/master/README.md):

```
    _______       ___________________       __________
    |Nginx| ----> |google_auth_proxy| ----> |upstream| 
    -------       -------------------       ----------
                          ||
                          \/
                  [google oauth2 api]
```

## Setup

### What google_auth_proxy affects

* google_auth_proxy itself is a single, self-contained executable
* nginx is installed and configured as a front end to the proxy
* a service instance is created to run the proxy

### Setup Requirements **OPTIONAL**

Make a note of the IP/hostname and port on which your application is running. Typically the proxy and application would run on the same node with the application bound to a high-numbered port and listening on localhost.

Follow the instructions in the [README](https://github.com/bitly/google_auth_proxy/blob/master/README.md) to set up your OAuth configuration with Google and make a note of your **Client ID** and **Client Secret**.

The google_auth_proxy RPM should be made available in a yum repo that has been configured on the target system. Both source and binary RPMs are available in [my yum repo](http://repo.yo61.net/el/7/).

Sample puppet code to configure the repo:
```puppet
yumrepo{'yo61':
  ensure   => present,
  name     => 'yo61',
  baseurl  => "http://repo.yo61.net/el/${::operatingsystemmajrelease}/${::architecture}/RPMS",
  enabled  => 1,
  gpgcheck => 1,
  gpgkey   => 'http://repo.yo61.net/RPM-GPG-KEY-YO61',
}
```

### Beginning with google_auth_proxy

Creating the proxy is as simple as this:
```puppet
  $redirect_url = 'https://your_app.example.com/oauth2/callback',
  $auth_domains = ['your_domain.com']
  $upstreams = ['http://localhost:8080']
  $cookie_secret = <seed string for secure cookies>
  $client_id = <your client id>
  $client_secret = <your client secret>

  google_auth_proxy{'puppetboard_stage':
    redirect_url        => $redirect_url,
    google_apps_domains => $auth_domains,
    upstreams           => $upstreams,
    cookie_secret       => $cookie_secret,
    client_id           => $client_id,
    client_secret       => $client_secret,
  }
```
This will create a nginx vhost listening on port 80 on all IP addresses with the proxy app listening on port 4180 on localhost.
## Usage

###Classes and Defined Types

####Defined Type: `google_auth_proxy`
This is the only public component of the module. It installs and sets up the google_auth_proxy service.

**Parameters within `google_auth_proxy`:**
#####`ensure`
Specify whether the proxy is present or absent.
Defaults to 'present'.
Valid values are 'present' and 'absent'.
#####`redirect_url`
The OAuth Redirect URL. eg. `https://your_app.example.com/oauth2/callback`
#####`google_apps_domains`
Authenticate against the given Google apps domain. May contain multiple values, ie. can be a string or an array of strings.
#####`upstreams`
The http url(s) of the upstream endpoint. May contain multiple values, ie. can be a string or an array of strings. If multiple, routing is based on path (what does this even mean?)
#####`cookie_secret`
The seed string for secure cookies.
#####`client_id`
The Google OAuth Client ID: ie: "123456.apps.googleusercontent.com"
#####`client_secret`
The OAuth Client Secret
#####`proxy_host`
The IP on which the nginx instance should listen.
Default: '*' (all IPs)
#####`proxy_port`
The port on which the nginx instance should listen.
Default: '80'.
#####`proxy_connect_timeout`
Timeout for the connection to the upstream server, ie. nginx -> google_auth_proxy
Default: 1
#####`proxy_read_timeout`
Timeout for the response of the upstream server, ie. the google_auth_proxy
Default: 30
#####`gap_host`
Hostname or IP on which the google_auth_proxy daemon should listen.
Default: 'localhost'
#####`gap_port`
Port on which he google_auth_proxy daemon should listen.
Default: '4180'
#####`gap_upstream_fail_timeout`
See: http://wiki.nginx.org/HttpUpstreamModule#server
Default: '10s'
#####`user`
The user as which the google_auth_proxy daemon will run.
Default: 'root'
#####`group`
The group as which the google_auth_proxy daemon will run.
Default: 'root'

## Reference

To be written

## Limitations

This module was written and tested on CentOS 7. It could be modified to work on other platforms but I have no need to do so at the present time. PRs (with tests) welcome :)

## Development

Feel free to improve anything.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

