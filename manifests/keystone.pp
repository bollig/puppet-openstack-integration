class openstack_integration::keystone {

  class { '::keystone::client': }
  class { '::keystone::cron::token_flush': }
  class { '::keystone::db::mysql':
    password => 'keystone',
  }
  class { '::keystone':
    verbose             => true,
    debug               => true,
    database_connection => "mysql+pymysql://keystone:keystone@127.0.0.1/keystone",
    admin_token         => 'admin_token',
# EVAN: control the service
    enabled             => true,
    service_name        => 'httpd',
# Evan: the keystone api runs behind Apache. no need to enable here
# since its enabled in the keystone::wsgi::apache class
    enable_ssl 		=> false,
    public_endpoint     => 'https://localhost:5000',
    admin_endpoint     => 'https://localhost:35357',
  }

  include ::apache
  class { '::keystone::wsgi::apache':
	# Evan: Enable SSL; remember to set the endpoints
    ssl     => true,
    workers => 2,
    ssl_cert        => "/etc/pki/tls/certs/ssl_dashboard.crt",
    ssl_key         => "/etc/pki/tls/private/ssl_dashboard.key",
    ssl_ca          => "/etc/pki/tls/certs/packstack_cacert.crt",
  }
  class { '::keystone::roles::admin':
    email    => 'admin@localhost',
    password => 'a_big_secret',
  }
  class { '::keystone::endpoint':
# Evan: Adjust these endpoints to match the hostname in the cert
    admin_url => "https://127.0.0.1:35357/",
    public_url => "https://127.0.0.1:5000/",
  }

# EVAN: the following configure settings in conf files (e.g.,
# glance_registry_config ==> /etc/glance/glance_registry.conf; and vars are
# 'section/setting' ==> [section]\nsetting ) 
   glance_registry_config {
	 'keystone_authtoken/insecure': value => true; 
   }
   glance_api_config {
	 'keystone_authtoken/insecure': value => true; 
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
	 'keystone_authtoken/auth_protocol': value => 'https';
	 'keystone_authtoken/service_protocol': value => 'https';
   }
   cinder_api_paste_ini {
	 'filter:authtoken/auth_version': value => 'v2.0';
	 'filter:authtoken/auth_uri': value => 'https://127.0.0.1:5000/v2.0';
	 'filter:authtoken/identity_uri': value => 'https://127.0.0.1:35357/';
	 'filter:authtoken/insecure': value => true; 
   }

}
