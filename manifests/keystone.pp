class openstack_integration::keystone {

  class { '::keystone::client': }
  class { '::keystone::cron::token_flush': }
  class { '::keystone::db::mysql':
    password => 'keystone',
    #allowed_hosts => [ '127.0.0.1', 'localhost' ],
  }
  class { '::keystone':
    verbose             => true,
    debug               => true,
    database_connection => "mysql+pymysql://keystone:keystone@127.0.0.1/keystone",
    admin_token         => 'admin_token',
# EVAN: disabled for ssl support through wsgi
    enabled             => true,
    service_name        => 'httpd',
	# Evan: 
    enable_ssl 		=> false,
    public_endpoint     => 'https://localhost:5000',
    admin_endpoint     => 'https://localhost:35357',
	# These come from the packstack generated cert
    #ssl_cert_subject => '/C=--/ST=State/L=City/O=openstack/OU=packstack/CN=localhost.localdomain/E=admin@localhost.localdomain',
    #ssl_certfile        => "/etc/pki/tls/certs/ssl_dashboard.crt",
    #ssl_keyfile         => "/etc/pki/tls/private/ssl_dashboard.key",
    #ssl_ca_key          => "/etc/pki/tls/certs/packstack_cacert.crt",
	# NEcessary until we have a CA signed cert
    #validate_insecure   => true,
    #default_domain => 'Default',
  }

  include ::apache
  class { '::keystone::wsgi::apache':
	# Evan: 
    ssl     => true,
#    #workers => 2,
    ssl_cert        => "/etc/pki/tls/certs/ssl_dashboard.crt",
    ssl_key         => "/etc/pki/tls/private/ssl_dashboard.key",
    ssl_ca          => "/etc/pki/tls/certs/packstack_cacert.crt",
  }
  class { '::keystone::roles::admin':
    email    => 'admin@localhost',
    password => 'a_big_secret',
  }
  class { '::keystone::endpoint':
 #   default_domain => 'admin',
  #  # Evan: This way we force the hostname to match the cert
    admin_url => "https://127.0.0.1:35357/",
    public_url => "https://127.0.0.1:5000/",
  }

   glance_registry_config {
	 'keystone_authtoken/insecure': value => true; 
	 #'keystone_authtoken/identity_uri': value => 'https://127.0.0.1:35357/'; 
   }
   glance_api_config {
	 'keystone_authtoken/insecure': value => true; 
	 #'keystone_authtoken/identity_uri': value => 'https://127.0.0.1:35357/'; 
   }
   neutron_config {
	 'keystone_authtoken/insecure': value => true; 
	 'keystone_authtoken/auth_version': value => 'v2.0';
	 'nova/insecure': value => true; 
	 'DEFAULT/nova_api_insecure': value => true; 
   }
   neutron_api_config {
	 'keystone_authtoken/insecure': value => true; 
	 'filter:authtoken/auth_version': value => 'v2.0';
   }
   nova_config {
	 'keystone_authtoken/insecure': value => true; 
   }
   cinder_config {
	 'keystone_authtoken/insecure': value => true; 
	 'keystone_authtoken/auth_version': value => 'v2.0';
#	 'keystone_authtoken/user_domain_id': value => 'default'; 
#	 'keystone_authtoken/auth_host': value => '127.0.0.1';
#	 'keystone_authtoken/service_port': value => '5000';
#	 'keystone_authtoken/auth_port': value => '35357';
	 #'keystone_authtoken/auth_uri': value => 'https://127.0.0.1:5000/v2.0';
	 'keystone_authtoken/auth_protocol': value => 'https';
	 'keystone_authtoken/service_protocol': value => 'https';
	 #'DEFAULT/nova_api_insecure': value => true; 
	 #'DEFAULT/insecure': value => true; 
   }
   cinder_api_paste_ini {
	 #'keystone_authtoken/insecure': value => true; 
	 #'keystone_authtoken/auth_version': value => 'v2.0';
	 #'keystone_authtoken/user_domain_id': value => 'default'; 
	 'filter:authtoken/auth_version': value => 'v2.0';
	 #'filter:authtoken/auth_host': value => '127.0.0.1';
	 #'filter:authtoken/service_port': value => '5000';
	 #'filter:authtoken/auth_port': value => '35357';
	 'filter:authtoken/auth_uri': value => 'https://127.0.0.1:5000/v2.0';
	 'filter:authtoken/identity_uri': value => 'https://127.0.0.1:35357/';
	 #'filter:authtoken/auth_protocol': value => 'https';
	 #'filter:authtoken/service_protocol': value => 'https';
	 'filter:authtoken/insecure': value => true; 
	 #'DEFAULT/nova_api_insecure': value => true; 
	 #'DEFAULT/insecure': value => true; 
   }

    #keystone::resource::authtoken { 'neutron_api_config':
#	username => 'admin', 
#	password => 'a_big_secret',
#	auth_url => 'https://localhost:35357/',
#	insecure => true,
#	project_name => 'admin', 
#	default_domain_name => 'admin', 
#     }
#    keystone::resource::authtoken { 'glance_api_config':
#	username => 'admin', 
#	password => 'a_big_secret',
#	auth_url => 'https://localhost:35357/',
#	insecure => true,
#	project_name => 'admin', 
#	default_domain_name => 'admin', 
#     }
}
