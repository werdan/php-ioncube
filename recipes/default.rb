include_recipe "php"
pkgs = ["wget"]

pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

case node[:kernel][:machine]
when 'x86_64'
  arch = 'x86-64'
when /i[36]86/
  arch = 'x86'
else
  arch = node[:kernel][:machine]
end

Chef::Log.info("using ionCube architecture #{arch}")

remote_file "/usr/local/src/ioncube_loaders_lin_#{arch}.tar.gz" do
  source "http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_#{arch}.tar.gz"
  mode "0644"
  action :create_if_missing
  notifies :run, "script[extract_ioncube_php]", :immediately
end

script "extract_ioncube_php" do
  interpreter "bash"
  user "root"
  cwd "/usr/local/src/"
  action :nothing
  code <<-EOH
  tar xvfz /usr/local/src/ioncube_loaders_lin_#{arch}.tar.gz
  mv /usr/local/src/ioncube /usr/local
  EOH
end

ruby_block "determine php version" do
  block do
    php_version_output = `php --version`
    php_version = php_version_output.match(/PHP ([0-9]+\.[0-9]+)\.[0-9]+/)[1]
    Chef::Log.info("detected PHP version #{php_version}")
    ioncube_file_resource = run_context.resource_collection.find(:file => "#{node['php']['ext_conf_dir']}/ioncube.ini")
    ioncube_file_resource.content "zend_extension=/usr/local/ioncube/ioncube_loader_lin_" + php_version + ".so\n"
  end
  only_if { node['php_ioncube']['version'] == '' }
end

file "#{node['php']['ext_conf_dir']}/ioncube.ini" do
  content "zend_extension=/usr/local/ioncube/ioncube_loader_lin_" + node['php_ioncube']['version'] + ".so\n"  # dynamically defined during convergence in above ruby_block
  owner "root"
  group "root"
  mode "0644"
  action :create_if_missing
  notifies :reload, resources(:service => "apache2")
end