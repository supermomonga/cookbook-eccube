name             'eccube'
maintainer       'Eido NABESHIMA'
maintainer_email 'closer009@gmail.com'
license          'All rights reserved'
description      'Installs/Configures EC-CUBE'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

recipe "EC-CUBE", "Installs and configures EC-CUBE LAMP stack on a single system"

%w{php openssl}.each do |cb|
  depends cb
end

depends "apache2", ">= 0.99.4"
depends "mysql", ">= 1.0.5"
depends "build-essential"

%w{ debian ubuntu }.each do |os|
    supports os
end
