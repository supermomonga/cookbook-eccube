execute "curl_install" do
  curl_commands = %w(welcome step0 step0_1 step1 step2 step3 step4 complete).map do |mode|
    "(echo \"mode=#{mode}&`cat /tmp/install_params`\") | curl http://localhost/install/ -X POST -d @-; "
  end
  command curl_commands.join
  not_if { ::File.exists? "#{node['eccube']['dir']}/data/config/config.php" }
  action :nothing
end

template "/tmp/install_params" do
  source "install_params.erb"
  not_if { ::File.exists? "#{node['eccube']['dir']}/data/config/config.php" }
  notifies :run, "execute[curl_install]", :immediately
end

execute "remove_install_dir" do
  command "rm #{node['eccube']['dir']}/html/install/index.php"
  only_if do
    ::File.exists?("#{node['eccube']['dir']}/data/config/config.php") && ::File.exists?("#{node['eccube']['dir']}/html/install/index.php")
  end
  action :run
end

