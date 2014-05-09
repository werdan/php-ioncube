# php-ioncube cookbook

Installs and configures Zend Ioncube extension

Works for Chef >= 11.0

# Usage

If you do not need to notify any resources (apache2, php-fpm), it is one line only:

    include_recipe "php-ioncube::install"
    
Otherwise, you'll need to use LWRP, like this:

    php_ioncube_install "ioncube" do
        action :install
        notifies :restart,"service['apache2']"
    end
