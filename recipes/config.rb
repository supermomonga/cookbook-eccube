if node['eccube']['db_skip'] == ""
  include_recipe "eccube::install"
else
  template "#{node['eccube']['dir']}/data/config/config.php" do
    source "config.php.erb"
    not_if { ::File.exists? "#{node['eccube']['dir']}/data/config/config.php" }
  end
end
