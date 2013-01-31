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

package {
	"zsh":
		ensure => installed,
		provider => apt;
	"imagemagick":
		ensure => installed,
		provider => apt;
	"libjpeg-progs":
		ensure => installed,
		provider => apt;
}

package { "python-pip": 
  ensure => latest,
}

package {
	"numpy": 
		ensure => latest,
		provider => pip,
		require => Package['python-pip'],
	"PIL": 
		ensure => latest,
		provider => pip,
		require => Package['python-pip'],
}

