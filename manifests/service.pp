define google_auth_proxy::service(
  $ensure = true,
) {

  # validate here

  include ::systemd

  $service_name = "gap_${name}"
  $unit_file = "/usr/lib/systemd/system/${service_name}.service"

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
  service{$service_name:
    ensure => $ensure ? {
      true    => 'running',
      default => 'stopped',
    },
    enable => $ensure,
  }

}