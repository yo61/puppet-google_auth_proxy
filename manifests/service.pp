define google_auth_proxy::service(
  $ensure = true,
) {

  # validate here

  include ::systemd

  $unit_file = "/usr/lib/systemd/system/${name}.service"

  file{$unit_file:
    ensure  => $ensure ? {
      true    => 'file',
      default => $ensure
    },
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/systemd_unit_file.erb"),
  } ~> Exec['systemctl-daemon-reload'] ->
  service{$name:
    ensure => $ensure ? {
      true    => 'running',
      default => 'stopped',
    },
    enable => $ensure,
  }

}