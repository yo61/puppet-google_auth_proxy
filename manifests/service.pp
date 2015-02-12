define google_auth_proxy::service(
  $ensure = 'present',
) {

  # validate here

  $service_name = "gap_${name}"
  $unit_file = "/usr/lib/systemd/system/${service_name}.service"

  $unit_file_ensure = $ensure ? {
    'present' => 'file',
    default   => $ensure
  }
  $service_ensure = $ensure ? {
    'present' => 'running',
    default   => 'stopped',
  }
  $service_enable = $ensure ? {
    'present' => true,
    default   => false,
  }
  file{$unit_file:
    ensure  => $unit_file_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/systemd_unit_file.erb"),
  }~>
  exec{"${name}-systemctl-daemon-reload":
    command     => 'systemctl daemon-reload',
    refreshonly => true,
    path        => $::path,
  }->
  service{$service_name:
    ensure => $service_ensure,
    enable => $service_enable,
  }
  File[$unit_file]~>
  Service[$service_name]

}