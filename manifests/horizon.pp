class openstack_integration::horizon {

  $vhost_params = { add_listen => true }
  class { '::horizon':
    secret_key         => 'big_secret',
    vhost_extra_params => $vhost_params,
    servername         => $::hostname,
    allowed_hosts      => $::hostname,
    server_aliases     => [ $::fqdn, $::hostname, localhost ], 
    # need to disable offline compression due to
    # https://bugs.launchpad.net/ubuntu/+source/horizon/+bug/1424042
    compress_offline   => false,
    listen_ssl => true,
    #ssl_no_verify       => true,
    horizon_cert          => "/etc/pki/tls/certs/ssl_dashboard.crt",
    horizon_key           => "/etc/pki/tls/private/ssl_dashboard.key",
    horizon_ca            => "/etc/pki/tls/certs/packstack_cacert.crt",
  }

}
