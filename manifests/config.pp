define google_auth_proxy::config(
  $redirect_url,
  $google_apps_domains,
  $upstreams,
  $cookie_secret,
  $client_id,
  $client_secret,
  $ensure = 'present',
  $user = 'root',
  $group = 'root',
  $mode = '0400',
) {

  # add validation here

  include ::google_auth_proxy::params
  $cfg_file = "${::google_auth_proxy::params::cfg_base}/${name}.cfg"
  $cfg_file_ensure = $ensure ? {
    'present' => 'file',
    default   => $ensure,
  }
  file{$cfg_file:
    ensure  => $cfg_file_ensure,
    owner   => $user,
    group   => $group,
    mode    => $mode,
    content => template("${module_name}/google_auth_proxy.cfg.erb")
  }

}