include_recipe "mysql::server"
include_recipe "mysql::ruby"

node.set_unless['eccube']['db']['password'] = secure_password

execute "mysql-install-eccube-privileges" do
  command "/usr/bin/mysql -u root -p\"#{node['mysql']['server_root_password']}\" <  /tmp/eccube-grants.sql"
  not_if { ::File.exists? "#{node['eccube']['dir']}/data/config/config.php" }
  action :nothing
end

template "/tmp/eccube-grants.sql" do
  source "grants.sql.erb"
  owner "root"
  group "root"
  mode "0600"
  variables(
    :user     => node['eccube']['db']['user'],
    :password => node['eccube']['db']['password'],
    :database => node['eccube']['db']['database']
  )
  notifies :run, "execute[mysql-install-eccube-privileges]", :immediately
end

execute "create #{node["eccube"]["db"]["database"]} database" do
  command "/usr/bin/mysqladmin -u root -p\"#{node['mysql']['server_root_password']}\" create #{node['eccube']['db']['database']}"
  not_if do
    # Make sure gem is detected if it was just installed earlier in this recipe
    require 'rubygems'
    Gem.clear_paths
    require 'mysql'
    m = Mysql.new("localhost", "root", node['mysql']['server_root_password'])
    m.list_dbs.include?(node['eccube']['db']['database'])
  end
  notifies :create, "ruby_block[save node data]", :immediately unless Chef::Config[:solo]
end


