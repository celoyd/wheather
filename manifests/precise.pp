exec { "apt-update":
  command => "/usr/bin/apt-get update"
}

# Ensure apt-get update has been run before installing any packages
Exec["apt-update"] -> Package <| |>

package {
    "build-essential":
        ensure => installed,
        provider => apt;
    "python":
        ensure => installed,
        provider => apt;
    "python-dev":
        ensure => installed,
        provider => apt;
    "python-setuptools":
        ensure => installed,
        provider => apt;
    "python-software-properties":
        ensure => installed,
        provider => apt;
}

package { "zsh":
	ensure => installed,
	provider => apt;
}

exec { "ppa:ubuntugis":
  command => "/usr/bin/add-apt-repository ppa:ubuntugis && /usr/bin/apt-get update",
  require => Package['python-software-properties'],
}

package { "gdal-bin":
  ensure => latest,
  require => Exec['ppa:ubuntugis'],
}

package { "python-gdal": 
  ensure => latest,
  require => Package['gdal-bin'],
}

package { "python-pip": 
  ensure => latest,
}

package { "numpy": 
  ensure => latest,
  provider => pip,
  require => Package['python-pip'],
}

package { "homebrew": 
  ensure => latest,
}

package { "imagemagick": 
  ensure => latest,
  provider => brew,
  require => Package['homebrew'],
}

package { "jpeg": 
  ensure => latest,
  provider => brew,
  require => Package['homebrew'],
}




