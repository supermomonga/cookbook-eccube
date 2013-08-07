#
# Cookbook Name:: cookbook-eccube
# Recipe:: default
#
# Copyright (C) 2013 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "apache2"
include_recipe "mysql::server"
include_recipe "php"
include_recipe "php::module_mysql"
include_recipe "apache2::mod_php5"

default['php']['directives'] = { "date.timezone" => "Asia/Tokyo" }

case node["platform_family"]
when 'rhel', 'fedora'
  if node['platform_version'].to_f < 6 then
    default['php']['packages'] = ['php53', 'php53-devel', 'php53-cli', 'php53-mbstring', 'php-pear']
  else
    default['php']['packages'] = ['php', 'php-devel', 'php-cli', 'php-mbstring', 'php-pear']
  end
end

if node.has_key?("ec2")
  server_fqdn = node['ec2']['public_hostname']
else
  server_fqdn = node['fqdn']
end

node.set_unless['eccube']['db']['password'] = secure_password
# node.set_unless['eccube']['keys']['auth'] = secure_password
# node.set_unless['eccube']['keys']['secure_auth'] = secure_password
# node.set_unless['eccube']['keys']['logged_in'] = secure_password
# node.set_unless['eccube']['keys']['nonce'] = secure_password

remote_file "#{Chef::Config[:file_cache_path]}/eccube-#{node['eccube']['version']}.tar.gz" do
  source "#{node['eccube']['repourl']}/eccube-#{node['eccube']['version']}.tar.gz"
  mode "0644"
end

directory node["eccube"]["dir"] do
  owner "root"
  group "root"
  mode "0755"
  action :create
  recursive true
end

execute "untar-eccube" do
  cwd node["eccube"]["dir"]
  command "tar --strip-components 1 -xzf #{Chef::Config[:file_cache_path]}/eccube-#{node['eccube']['version']}.tar.gz"
end

execute "mysql-install-eccube-privileges" do
  command "/usr/bin/mysql -u root -p\"#{node['mysql']['server_root_password']}\" grant all privileges on #{node['eccube']['db']['database']}.* to #{node['eccube']['db']['user']}@localhost"
  action :nothing
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

# unless Chef::Config[:solo]
#   ruby_block "save node data" do
#     block do
#       node.save
#     end
#     action :create
#   end
# end

apache_site "000-default" do
  enable false
end

web_app "eccube" do
  template "eccube.conf.erb"
  docroot node["eccube"]["dir"]
  server_name server_fqdn
  server_aliases node["eccube"]["server_aliases"]
end
