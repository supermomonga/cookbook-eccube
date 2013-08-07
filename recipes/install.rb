template "#{node['eccube']['dir']}/data/config/config.php" do
  source "config.php.erb"
  owner "root"
  group "root"
  mode "0666"
  variables(
    :hostname   => node['fqdn'],
    :dbname     => node['eccube']['db']['database'],
    :dbuser     => node['eccube']['db']['user'],
    :dbpassword => node['eccube']['db']['password'],
    :auth_magic => 'eccubeauthmagic'
  )
end
