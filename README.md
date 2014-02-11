# php-ioncube cookbook

Installs and configures Zend Ioncube extension

# Usage

include_recipe "php-ioncube"

Add the [:php_ioncube][:version] attribute to your node to set the
php version, else the version is determined from the installed version
of PHP: 

"php_ioncube": {
  "version":"5.4"
},
