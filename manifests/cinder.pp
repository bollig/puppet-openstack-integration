class openstack_integration::cinder {

  rabbitmq_user { 'cinder':
    admin    => true,
    password => 'an_even_bigger_secret',
    provider => 'rabbitmqctl',
    require  => Class['::rabbitmq'],
  }
  rabbitmq_user_permissions { 'cinder@/':
    configure_permission => '.*',
    write_permission     => '.*',
    read_permission      => '.*',
    provider             => 'rabbitmqctl',
    require              => Class['::rabbitmq'],
  }

  class { '::cinder::db::mysql':
    password => 'cinder',
  }
  class { '::cinder::keystone::auth':
    password => 'a_big_secret',
  }
  class { '::cinder':
    database_connection => 'mysql+pymysql://cinder:cinder@127.0.0.1/cinder?charset=utf8',
    rabbit_host         => '127.0.0.1',
    rabbit_userid       => 'cinder',
    rabbit_password     => 'an_even_bigger_secret',
    verbose             => true,
    debug               => true,
  }
  class { '::cinder::api':
    keystone_password   => 'a_big_secret',
    identity_uri        => 'https://127.0.0.1:35357/',
    default_volume_type => 'BACKEND_1',
    service_workers     => 2,
    auth_uri 		=> 'https://127.0.0.1:5000/v2.0',
    keystone_tenant	=> 'services',
    os_region_name	=> 'RegionOne',
  }
  class { '::cinder::quota': }
  class { '::cinder::scheduler': }
  class { '::cinder::scheduler::filter': }
  class { '::cinder::volume': }
  class { '::cinder::cron::db_purge': }
  class { '::cinder::glance':
    glance_api_servers  => 'localhost:9292',
  }
  class { '::cinder::setup_test_volume':
    size => '5G',
  }
  cinder::backend::iscsi { 'BACKEND_1':
    iscsi_ip_address => '127.0.0.1',
  }
  class { '::cinder::backends':
    enabled_backends => ['BACKEND_1'],
  }
  Cinder::Type {
    os_password    => 'a_big_secret',
    os_tenant_name => 'services',
    os_username    => 'cinder',
    os_auth_url    => 'https://127.0.0.1:5000/v2.0',
    os_region_name => 'RegionOne',
  }
  cinder::type { 'BACKEND_1':
    set_key   => 'volume_backend_name',
    set_value => 'BACKEND_1',
    notify    => Service['cinder-volume'],
    require   => Service['cinder-api'],
  }

}
