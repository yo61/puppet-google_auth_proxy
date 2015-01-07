define google_auth_proxy::service(
  $ensure = 'present',
) {

  # validate here

  include ::systemd

  $service_name = "gap_${name}"
  $unit_file = "/usr/lib/systemd/system/${service_name}.service"

  file{$unit_file:
    ensure  => $ensure ? {
      'present' => 'file',
      default   => $ensure
    },
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/systemd_unit_file.erb"),
  } ~> Exec['systemctl-daemon-reload'] ->
  service{$service_name:
    ensure => $ensure ? {
      'present' => 'running',
      default   => 'stopped',
    },
    enable => $ensure ? {
      'present' => true,
      default   => false,
    },
  }

}