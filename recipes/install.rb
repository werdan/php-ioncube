include_recipe 'php-ioncube::default'

php_ioncube_install "ioncube" do
    action :install
end
