# Class facter::fact
#
# Manage file based customized fact
#

define facter::fact (
  $file               = $facter::facts_file,
  $facts_dir          = $facter::facts_d_dir,
  $fact               = $name,
  $value              = undef,
  $value_hiera_merge  = undef,
  $match              = "^${name}=\\S*$",
  $separator          = $facter::fact_separator,
) {

  if type($value_hiera_merge) == 'string' {
    $value_hiera_merge_real = str2bool($value_hiera_merge)
  } else {
    $value_hiera_merge_real = $value_hiera_merge
  }
  validate_bool($value_hiera_merge_real)

  if $value_hiera_merge_real == true {
    $hiera_value = hiera_hash('facter::facts')
    $value_temp = $hiera_value[$name]['value']
  } else {
    $value_temp = $value
  }

  validate_string($separator)

  if is_array($value_temp)  {
    $value_real = join($value_temp, $separator)
  } else {
    $value_real = $value_temp
  }

  if $file != $facter::facts_file {
    file { "facts_file_${name}":
      ensure  => file,
      path    => "${facts_dir}/${file}",
      owner   => $facter::facts_file_owner,
      group   => $facter::facts_file_group,
      mode    => $facter::facts_file_mode,
      require => File['facts_d_directory'],
    }
  }

  file_line { "fact_line_${name}":
    path  => "${facts_dir}/${file}",
    line  => "${name}=${value_real}",
    match => $match,
  }
}

