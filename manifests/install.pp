class google_auth_proxy::install(
  $version = 'installed',
) {

  include ::google_auth_proxy::params
  package{$::google_auth_proxy::params::package_name:
    ensure => $version,
  }

}