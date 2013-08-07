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
include_recipe "mysql::ruby"
include_recipe "php"
include_recipe "php::module_mysql"
include_recipe "apache2::mod_php5"

if node.has_key?("ec2")
  server_fqdn = node['ec2']['public_hostname']
else
  server_fqdn = node['fqdn']
end

node.set_unless['eccube']['db']['password'] = secure_password

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
  command "/usr/bin/mysql -u root -p\"#{node['mysql']['server_root_password']}\" <  #{node['eccube']['dir']}/grants.sql"
  action :nothing
end

apache_site "000-default" do
  enable false
end

web_app "eccube" do
  template "eccube.conf.erb"
  docroot node["eccube"]["dir"]
  server_name server_fqdn
  server_aliases node["eccube"]["server_aliases"]
end

require 'json'

file "/tmp/dna.json" do
  content JSON.pretty_generate(node)
end

