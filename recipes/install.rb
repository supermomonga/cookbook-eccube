%w(welcome step0 step0_1 step1 step2 step3 step4 complete).each do |mode|
  execute "curl_install_#{mode}" do
    command "curl http://localhost/install/ -X POST -d @- < /tmp/install_params_#{mode} "
    action :nothing
  end

  template "/tmp/install_params_#{mode}" do
    source "install_params.erb"
    variables(:mode => mode)
    only_if { ::File.exists? "#{node['eccube']['dir']}/html/install/index.php" }
    notifies :run, "execute[curl_install_#{mode}]", :immediately
  end
end

execute "remove_install_dir" do
  command "rm #{node['eccube']['dir']}/html/install/index.php"
  action :run
end

