# WARNING: this file is generated, do not edit
# generated on Thu Jul 29 18:12:40 2010
# 01: /usr/lib/perl5/vendor_perl/5.12.0/Apache/TestConfig.pm:955
# 02: /usr/lib/perl5/vendor_perl/5.12.0/Apache/TestConfig.pm:973
# 03: /usr/lib/perl5/vendor_perl/5.12.0/Apache/TestConfig.pm:1870
# 04: /usr/lib/perl5/vendor_perl/5.12.0/Apache/TestRun.pm:508
# 05: /usr/lib/perl5/vendor_perl/5.12.0/Apache/TestRun.pm:725
# 06: /usr/lib/perl5/vendor_perl/5.12.0/Apache/TestRun.pm:725
# 07: /home/guillaume/work/fusioninventory/fusioninventory-agent/t/TEST:4

package apache_test_config;

sub new {
    bless( {
                 'verbose' => undef,
                 'hostport' => 'localhost.localdomain:8529',
                 'postamble' => [
                                  '<IfModule mod_mime.c>
    TypesConfig "/etc/httpd/conf/mime.types"
</IfModule>
',
                                  ''
                                ],
                 'mpm' => 'prefork',
                 'inc' => [],
                 'APXS' => undef,
                 'save' => 1,
                 'vhosts' => {},
                 'httpd_basedir' => '/usr',
                 'server' => bless( {
                                      'run' => bless( {
                                                        'conf_opts' => {
                                                                         'verbose' => undef,
                                                                         'save' => 1
                                                                       },
                                                        'test_config' => $VAR1,
                                                        'tests' => [],
                                                        'opts' => {
                                                                    'breakpoint' => [],
                                                                    'postamble' => [],
                                                                    'ssl' => 1,
                                                                    'preamble' => [],
                                                                    'req_args' => {},
                                                                    'header' => {}
                                                                  },
                                                        'argv' => [],
                                                        'server' => $VAR1->{'server'}
                                                      }, 'Apache::TestRun' ),
                                      'port_counter' => 8529,
                                      'mpm' => 'prefork',
                                      'version' => 'Apache/2.2.16',
                                      'rev' => '2',
                                      'name' => 'localhost.localdomain:8529',
                                      'config' => $VAR1
                                    }, 'Apache::TestServer' ),
                 'postamble_hooks' => [
                                        sub { "DUMMY" }
                                      ],
                 'inherit_config' => {
                                       'ServerRoot' => '/etc/httpd',
                                       'ServerAdmin' => 'root@localhost',
                                       'TypesConfig' => 'conf/mime.types',
                                       'DocumentRoot' => '/var/www/html',
                                       'LoadModule' => [
                                                         [
                                                           'authn_file_module',
                                                           'modules/mod_authn_file.so'
                                                         ],
                                                         [
                                                           'authn_anon_module',
                                                           'modules/mod_authn_anon.so'
                                                         ],
                                                         [
                                                           'authn_default_module',
                                                           'modules/mod_authn_default.so'
                                                         ],
                                                         [
                                                           'authn_alias_module',
                                                           'modules/mod_authn_alias.so'
                                                         ],
                                                         [
                                                           'authz_host_module',
                                                           'modules/mod_authz_host.so'
                                                         ],
                                                         [
                                                           'authz_groupfile_module',
                                                           'modules/mod_authz_groupfile.so'
                                                         ],
                                                         [
                                                           'authz_user_module',
                                                           'modules/mod_authz_user.so'
                                                         ],
                                                         [
                                                           'authz_dbm_module',
                                                           'modules/mod_authz_dbm.so'
                                                         ],
                                                         [
                                                           'authz_owner_module',
                                                           'modules/mod_authz_owner.so'
                                                         ],
                                                         [
                                                           'authz_default_module',
                                                           'modules/mod_authz_default.so'
                                                         ],
                                                         [
                                                           'auth_basic_module',
                                                           'modules/mod_auth_basic.so'
                                                         ],
                                                         [
                                                           'auth_digest_module',
                                                           'modules/mod_auth_digest.so'
                                                         ],
                                                         [
                                                           'include_module',
                                                           'modules/mod_include.so'
                                                         ],
                                                         [
                                                           'filter_module',
                                                           'modules/mod_filter.so'
                                                         ],
                                                         [
                                                           'substitute_module',
                                                           'modules/mod_substitute.so'
                                                         ],
                                                         [
                                                           'log_config_module',
                                                           'modules/mod_log_config.so'
                                                         ],
                                                         [
                                                           'env_module',
                                                           'modules/mod_env.so'
                                                         ],
                                                         [
                                                           'mime_magic_module',
                                                           'modules/mod_mime_magic.so'
                                                         ],
                                                         [
                                                           'expires_module',
                                                           'modules/mod_expires.so'
                                                         ],
                                                         [
                                                           'headers_module',
                                                           'modules/mod_headers.so'
                                                         ],
                                                         [
                                                           'usertrack_module',
                                                           'modules/mod_usertrack.so'
                                                         ],
                                                         [
                                                           'unique_id_module',
                                                           'modules/mod_unique_id.so'
                                                         ],
                                                         [
                                                           'setenvif_module',
                                                           'modules/mod_setenvif.so'
                                                         ],
                                                         [
                                                           'version_module',
                                                           'modules/mod_version.so'
                                                         ],
                                                         [
                                                           'mime_module',
                                                           'modules/mod_mime.so'
                                                         ],
                                                         [
                                                           'status_module',
                                                           'modules/mod_status.so'
                                                         ],
                                                         [
                                                           'autoindex_module',
                                                           'modules/mod_autoindex.so'
                                                         ],
                                                         [
                                                           'info_module',
                                                           'modules/mod_info.so'
                                                         ],
                                                         [
                                                           'cgi_module',
                                                           'modules/mod_cgi.so'
                                                         ],
                                                         [
                                                           'vhost_alias_module',
                                                           'modules/mod_vhost_alias.so'
                                                         ],
                                                         [
                                                           'negotiation_module',
                                                           'modules/mod_negotiation.so'
                                                         ],
                                                         [
                                                           'dir_module',
                                                           'modules/mod_dir.so'
                                                         ],
                                                         [
                                                           'imagemap_module',
                                                           'modules/mod_imagemap.so'
                                                         ],
                                                         [
                                                           'actions_module',
                                                           'modules/mod_actions.so'
                                                         ],
                                                         [
                                                           'alias_module',
                                                           'modules/mod_alias.so'
                                                         ],
                                                         [
                                                           'rewrite_module',
                                                           'modules/mod_rewrite.so'
                                                         ],
                                                         [
                                                           'ssl_module',
                                                           'modules/mod_ssl.so'
                                                         ],
                                                         [
                                                           'php5_module',
                                                           'extramodules/mod_php5.so'
                                                         ],
                                                         [
                                                           'perl_module',
                                                           'extramodules/mod_perl.so'
                                                         ],
                                                         [
                                                           'ssl_module',
                                                           'modules/mod_ssl.so'
                                                         ]
                                                       ],
                                       'LoadFile' => []
                                     },
                 'cmodules_disabled' => {},
                 'preamble_hooks' => [
                                       sub { "DUMMY" }
                                     ],
                 'preamble' => [
                                 '<IfModule !mod_authn_file.c>
    LoadModule authn_file_module "/etc/httpd/modules/mod_authn_file.so"
</IfModule>
',
                                 '<IfModule !mod_authn_anon.c>
    LoadModule authn_anon_module "/etc/httpd/modules/mod_authn_anon.so"
</IfModule>
',
                                 '<IfModule !mod_authn_default.c>
    LoadModule authn_default_module "/etc/httpd/modules/mod_authn_default.so"
</IfModule>
',
                                 '<IfModule !mod_authn_alias.c>
    LoadModule authn_alias_module "/etc/httpd/modules/mod_authn_alias.so"
</IfModule>
',
                                 '<IfModule !mod_authz_host.c>
    LoadModule authz_host_module "/etc/httpd/modules/mod_authz_host.so"
</IfModule>
',
                                 '<IfModule !mod_authz_groupfile.c>
    LoadModule authz_groupfile_module "/etc/httpd/modules/mod_authz_groupfile.so"
</IfModule>
',
                                 '<IfModule !mod_authz_user.c>
    LoadModule authz_user_module "/etc/httpd/modules/mod_authz_user.so"
</IfModule>
',
                                 '<IfModule !mod_authz_dbm.c>
    LoadModule authz_dbm_module "/etc/httpd/modules/mod_authz_dbm.so"
</IfModule>
',
                                 '<IfModule !mod_authz_owner.c>
    LoadModule authz_owner_module "/etc/httpd/modules/mod_authz_owner.so"
</IfModule>
',
                                 '<IfModule !mod_authz_default.c>
    LoadModule authz_default_module "/etc/httpd/modules/mod_authz_default.so"
</IfModule>
',
                                 '<IfModule !mod_auth_basic.c>
    LoadModule auth_basic_module "/etc/httpd/modules/mod_auth_basic.so"
</IfModule>
',
                                 '<IfModule !mod_auth_digest.c>
    LoadModule auth_digest_module "/etc/httpd/modules/mod_auth_digest.so"
</IfModule>
',
                                 '<IfModule !mod_include.c>
    LoadModule include_module "/etc/httpd/modules/mod_include.so"
</IfModule>
',
                                 '<IfModule !mod_filter.c>
    LoadModule filter_module "/etc/httpd/modules/mod_filter.so"
</IfModule>
',
                                 '<IfModule !mod_substitute.c>
    LoadModule substitute_module "/etc/httpd/modules/mod_substitute.so"
</IfModule>
',
                                 '<IfModule !mod_log_config.c>
    LoadModule log_config_module "/etc/httpd/modules/mod_log_config.so"
</IfModule>
',
                                 '<IfModule !mod_env.c>
    LoadModule env_module "/etc/httpd/modules/mod_env.so"
</IfModule>
',
                                 '<IfModule !mod_mime_magic.c>
    LoadModule mime_magic_module "/etc/httpd/modules/mod_mime_magic.so"
</IfModule>
',
                                 '<IfModule !mod_expires.c>
    LoadModule expires_module "/etc/httpd/modules/mod_expires.so"
</IfModule>
',
                                 '<IfModule !mod_headers.c>
    LoadModule headers_module "/etc/httpd/modules/mod_headers.so"
</IfModule>
',
                                 '<IfModule !mod_usertrack.c>
    LoadModule usertrack_module "/etc/httpd/modules/mod_usertrack.so"
</IfModule>
',
                                 '<IfModule !mod_unique_id.c>
    LoadModule unique_id_module "/etc/httpd/modules/mod_unique_id.so"
</IfModule>
',
                                 '<IfModule !mod_setenvif.c>
    LoadModule setenvif_module "/etc/httpd/modules/mod_setenvif.so"
</IfModule>
',
                                 '<IfModule !mod_version.c>
    LoadModule version_module "/etc/httpd/modules/mod_version.so"
</IfModule>
',
                                 '<IfModule !mod_mime.c>
    LoadModule mime_module "/etc/httpd/modules/mod_mime.so"
</IfModule>
',
                                 '<IfModule !mod_status.c>
    LoadModule status_module "/etc/httpd/modules/mod_status.so"
</IfModule>
',
                                 '<IfModule !mod_autoindex.c>
    LoadModule autoindex_module "/etc/httpd/modules/mod_autoindex.so"
</IfModule>
',
                                 '<IfModule !mod_info.c>
    LoadModule info_module "/etc/httpd/modules/mod_info.so"
</IfModule>
',
                                 '<IfModule !mod_cgi.c>
    LoadModule cgi_module "/etc/httpd/modules/mod_cgi.so"
</IfModule>
',
                                 '<IfModule !mod_vhost_alias.c>
    LoadModule vhost_alias_module "/etc/httpd/modules/mod_vhost_alias.so"
</IfModule>
',
                                 '<IfModule !mod_negotiation.c>
    LoadModule negotiation_module "/etc/httpd/modules/mod_negotiation.so"
</IfModule>
',
                                 '<IfModule !mod_dir.c>
    LoadModule dir_module "/etc/httpd/modules/mod_dir.so"
</IfModule>
',
                                 '<IfModule !mod_imagemap.c>
    LoadModule imagemap_module "/etc/httpd/modules/mod_imagemap.so"
</IfModule>
',
                                 '<IfModule !mod_actions.c>
    LoadModule actions_module "/etc/httpd/modules/mod_actions.so"
</IfModule>
',
                                 '<IfModule !mod_alias.c>
    LoadModule alias_module "/etc/httpd/modules/mod_alias.so"
</IfModule>
',
                                 '<IfModule !mod_rewrite.c>
    LoadModule rewrite_module "/etc/httpd/modules/mod_rewrite.so"
</IfModule>
',
                                 '<IfModule !mod_ssl.c>
    LoadModule ssl_module "/etc/httpd/modules/mod_ssl.so"
</IfModule>
',
                                 '<IfModule !mod_php5.c>
    LoadModule php5_module "/etc/httpd/extramodules/mod_php5.so"
</IfModule>
',
                                 '<IfModule !mod_perl.c>
    LoadModule perl_module "/etc/httpd/extramodules/mod_perl.so"
</IfModule>
',
                                 '<IfModule !mod_ssl.c>
    LoadModule ssl_module "/etc/httpd/modules/mod_ssl.so"
</IfModule>
',
                                 '<IfModule !mod_mime.c>
    LoadModule mime_module "/etc/httpd/modules/mod_mime.so"
</IfModule>
',
                                 '<IfModule !mod_alias.c>
    LoadModule alias_module "/etc/httpd/modules/mod_alias.so"
</IfModule>
',
                                 ''
                               ],
                 'vars' => {
                             'defines' => '',
                             'cgi_module_name' => 'mod_cgi',
                             't_conf_file' => '/home/guillaume/work/fusioninventory/fusioninventory-agent/t/conf/httpd.conf',
                             't_dir' => '/home/guillaume/work/fusioninventory/fusioninventory-agent/t',
                             'cgi_module' => 'mod_cgi.c',
                             'target' => 'httpd',
                             'thread_module' => 'worker.c',
                             'user' => 'guillaume',
                             'access_module_name' => 'mod_authz_host',
                             'auth_module_name' => 'mod_auth_basic',
                             'top_dir' => '/home/guillaume/work/fusioninventory/fusioninventory-agent',
                             'httpd' => '/usr/sbin/httpd',
                             'scheme' => 'https',
                             'ssl_module_name' => 'mod_ssl',
                             'port' => 8529,
                             't_conf' => '/home/guillaume/work/fusioninventory/fusioninventory-agent/t/conf',
                             'servername' => 'localhost.localdomain',
                             'inherit_documentroot' => '/var/www/html',
                             'proxy' => 'off',
                             'serveradmin' => 'root@localhost',
                             'remote_addr' => '127.0.0.1',
                             'perlpod' => '/usr/lib/perl5/5.12.1/pod',
                             'sslcaorg' => 'asf',
                             'php_module_name' => 'mod_php5',
                             'maxclients_preset' => 0,
                             'php_module' => 'mod_php5.c',
                             'ssl_module' => 'mod_ssl.c',
                             'auth_module' => 'mod_auth_basic.c',
                             'access_module' => 'mod_authz_host.c',
                             't_logs' => '/home/guillaume/work/fusioninventory/fusioninventory-agent/t/logs',
                             'minclients' => 1,
                             'maxclients' => 2,
                             'group' => 'guillaume',
                             't_pid_file' => '/home/guillaume/work/fusioninventory/fusioninventory-agent/t/logs/httpd.pid',
                             'maxclientsthreadedmpm' => 2,
                             'thread_module_name' => 'worker',
                             'documentroot' => '/home/guillaume/work/fusioninventory/fusioninventory-agent/t/htdocs',
                             'serverroot' => '/home/guillaume/work/fusioninventory/fusioninventory-agent/t',
                             'sslca' => '/home/guillaume/work/fusioninventory/fusioninventory-agent/t/conf/ssl/ca',
                             'perl' => '/usr/bin/perl5.12.1',
                             'src_dir' => undef,
                             'proxyssl_url' => ''
                           },
                 'clean' => {
                              'files' => {
                                           '/home/guillaume/work/fusioninventory/fusioninventory-agent/t/conf/apache_test_config.pm' => 1,
                                           '/home/guillaume/work/fusioninventory/fusioninventory-agent/t/logs/apache_runtime_status.sem' => 1,
                                           '/home/guillaume/work/fusioninventory/fusioninventory-agent/t/conf/httpd.conf' => 1
                                         },
                              'dirs' => {
                                          '/home/guillaume/work/fusioninventory/fusioninventory-agent/t/conf' => 1
                                        }
                            },
                 'httpd_info' => {
                                   'BUILT' => 'Jul 26 2010 09:50:10',
                                   'MODULE_MAGIC_NUMBER_MINOR' => '24',
                                   'SERVER_MPM' => 'Prefork',
                                   'VERSION' => 'Apache/2.2.16 (Mandriva Linux/PREFORK-1mdv2011.0)',
                                   'MODULE_MAGIC_NUMBER' => '20051115:24',
                                   'MODULE_MAGIC_NUMBER_MAJOR' => '20051115'
                                 },
                 'modules' => {
                                'mod_include.c' => '/etc/httpd/modules/mod_include.so',
                                'mod_headers.c' => '/etc/httpd/modules/mod_headers.so',
                                'mod_negotiation.c' => '/etc/httpd/modules/mod_negotiation.so',
                                'mod_authn_file.c' => '/etc/httpd/modules/mod_authn_file.so',
                                'mod_php5.c' => '/etc/httpd/extramodules/mod_php5.so',
                                'mod_authz_user.c' => '/etc/httpd/modules/mod_authz_user.so',
                                'mod_usertrack.c' => '/etc/httpd/modules/mod_usertrack.so',
                                'mod_authz_owner.c' => '/etc/httpd/modules/mod_authz_owner.so',
                                'mod_setenvif.c' => '/etc/httpd/modules/mod_setenvif.so',
                                'mod_authn_anon.c' => '/etc/httpd/modules/mod_authn_anon.so',
                                'mod_authz_host.c' => '/etc/httpd/modules/mod_authz_host.so',
                                'mod_unique_id.c' => '/etc/httpd/modules/mod_unique_id.so',
                                'mod_authn_alias.c' => '/etc/httpd/modules/mod_authn_alias.so',
                                'mod_status.c' => '/etc/httpd/modules/mod_status.so',
                                'mod_log_config.c' => '/etc/httpd/modules/mod_log_config.so',
                                'mod_auth_digest.c' => '/etc/httpd/modules/mod_auth_digest.so',
                                'mod_env.c' => '/etc/httpd/modules/mod_env.so',
                                'mod_auth_basic.c' => '/etc/httpd/modules/mod_auth_basic.so',
                                'mod_version.c' => '/etc/httpd/modules/mod_version.so',
                                'core.c' => 1,
                                'mod_authz_groupfile.c' => '/etc/httpd/modules/mod_authz_groupfile.so',
                                'http_core.c' => 1,
                                'mod_dir.c' => '/etc/httpd/modules/mod_dir.so',
                                'mod_filter.c' => '/etc/httpd/modules/mod_filter.so',
                                'mod_imagemap.c' => '/etc/httpd/modules/mod_imagemap.so',
                                'prefork.c' => 1,
                                'mod_actions.c' => '/etc/httpd/modules/mod_actions.so',
                                'mod_cgi.c' => '/etc/httpd/modules/mod_cgi.so',
                                'mod_so.c' => 1,
                                'mod_mime_magic.c' => '/etc/httpd/modules/mod_mime_magic.so',
                                'mod_perl.c' => '/etc/httpd/extramodules/mod_perl.so',
                                'mod_expires.c' => '/etc/httpd/modules/mod_expires.so',
                                'mod_alias.c' => '/etc/httpd/modules/mod_alias.so',
                                'mod_authz_dbm.c' => '/etc/httpd/modules/mod_authz_dbm.so',
                                'mod_autoindex.c' => '/etc/httpd/modules/mod_autoindex.so',
                                'mod_rewrite.c' => '/etc/httpd/modules/mod_rewrite.so',
                                'mod_substitute.c' => '/etc/httpd/modules/mod_substitute.so',
                                'mod_authn_default.c' => '/etc/httpd/modules/mod_authn_default.so',
                                'mod_ssl.c' => '/etc/httpd/modules/mod_ssl.so',
                                'mod_authz_default.c' => '/etc/httpd/modules/mod_authz_default.so',
                                'mod_mime.c' => '/etc/httpd/modules/mod_mime.so',
                                'mod_vhost_alias.c' => '/etc/httpd/modules/mod_vhost_alias.so',
                                'mod_info.c' => '/etc/httpd/modules/mod_info.so'
                              },
                 'httpd_defines' => {
                                      'SUEXEC_BIN' => '/usr/sbin/suexec',
                                      'APR_USE_FCNTL_SERIALIZE' => 1,
                                      'APR_HAS_MMAP' => 1,
                                      'APR_HAS_OTHER_CHILD' => 1,
                                      'DEFAULT_PIDLOG' => '/var/run/httpd.pid',
                                      'DYNAMIC_MODULE_LIMIT' => '128',
                                      'AP_TYPES_CONFIG_FILE' => 'conf/mime.types',
                                      'DEFAULT_SCOREBOARD' => 'logs/apache_runtime_status',
                                      'DEFAULT_LOCKFILE' => '/var/run/accept.lock',
                                      'APR_HAVE_IPV6 (IPv4-mapped addresses enabled)' => 1,
                                      'SINGLE_LISTEN_UNSERIALIZED_ACCEPT' => 1,
                                      'APACHE_MPM_DIR' => 'server/mpm/prefork',
                                      'DEFAULT_ERRORLOG' => 'logs/error_log',
                                      'APR_HAS_SENDFILE' => 1,
                                      'HTTPD_ROOT' => '/etc/httpd',
                                      'AP_HAVE_RELIABLE_PIPED_LOGS' => 1,
                                      'SERVER_CONFIG_FILE' => 'conf/httpd.conf',
                                      'APR_USE_PTHREAD_SERIALIZE' => 1
                                    },
                 'apache_test_version' => '1.32'
               }, 'Apache::TestConfig' );
}

1;
