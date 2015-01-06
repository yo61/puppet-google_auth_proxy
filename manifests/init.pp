define google_auth_proxy(
  $ensure = true,
  $redirect_url,
  $google_apps_domains,
  $upstreams,
  $cookie_secret,
  $client_id,
  $client_secret,
  $proxy_host = '*',
  $proxy_port = '80',
  $proxy_connect_timeout = '1',
  #proxy_send_timeout = '30',
  $proxy_read_timeout = '30',
  $gap_host = 'localhost',
  $gap_port = '4180',
  $gap_upstream_fail_timeout = '10s',
  $user = 'root',
  $group = 'root',
) {

  # add validation here

  if $ensure == true {
    include ::google_auth_proxy::install
    include ::nginx
  }

  $app_name = "app_${name}"
  $gap_name = "gap_${name}"

  google_auth_proxy::config{$name:
    ensure              => $ensure,
    redirect_url        => $redirect_url,
    google_apps_domains => $google_apps_domains,
    upstreams           => $upstreams,
    cookie_secret       => $cookie_secret,
    client_id           => $client_id,
    client_secret       => $client_secret,
    user                => $user,
    group               => $group,
  }

  google_auth_proxy::service{$gap_name:
    ensure => $ensure,
  }

  nginx::resource::upstream{$gap_name:
    ensure           => $ensure ? {
      true    => 'present',
      default => 'absent',
    },
    members               => ["${gap_host}:${gap_port}"],
    upstream_fail_timeout => $gap_upstream_fail_timeout,
  }
  
  nginx::resource::vhost{$app_name:
    ensure           => $ensure ? {
      true    => 'present',
      default => 'absent',
    },
    listen_ip        => $listen_ip,
    listen_port      => $listen_port,
    proxy            => "http://${gap_name}",
    proxy_set_header => [
      'Host $host',
      'X-Real-IP $remote_addr',
      'X-Scheme $scheme',
    ],
    proxy_connect_timeout => '1',
    proxy_read_timeout    => '30',
    #proxy_send_timeout    => '30',
  }

}