override['php']['directives'] = { "date.timezone" => "Asia/Tokyo" }

case node["platform_family"]
when 'rhel', 'fedora'
  if node['platform_version'].to_f < 6 then
    override['php']['packages'] = ['php53', 'php53-devel', 'php53-cli', 'php-pear', 'php53-mbstring', 'php53-gd']
  else
    override['php']['packages'] = ['php', 'php-devel', 'php-cli', 'php-pear', 'php-mbstring', 'php-gd']
  end
end

default["eccube"]["version"] = "2.12.5"
default["eccube"]["checksum"] = ""
default["eccube"]["repourl"] = "http://downloads.ec-cube.net/src/"
default["eccube"]["dir"] = "/var/www/eccube"
default["eccube"]["hostname"] = node["fqdn"]
default["eccube"]["shop_name"] = "Chef Shop"
default["eccube"]["admin_mail"] = "test@example.com"
default["eccube"]["login_id"] = "admin"
default["eccube"]["login_pass"] = "admin"
default["eccube"]["db"]["database"] = "eccube_db"
default["eccube"]["db"]["user"] = "eccube_db_user"
default["eccube"]["server_aliases"] = [node["fqdn"]]
