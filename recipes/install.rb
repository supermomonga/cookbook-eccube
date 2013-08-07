execute "config" do
  command "/usr/bin/mysql -u root -p\"#{node['mysql']['server_root_password']}\" <  #{node['eccube']['dir']}/grants.sql"
  action :nothing
end

template "#{node['eccube']['dir']}/grants.sql" do
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


