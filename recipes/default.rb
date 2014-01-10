include_recipe "php"
pkgs = ["wget"]

pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

remote_file "/usr/local/src/ioncube_loaders_lin_x86-64.tar.gz" do
  source "http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz"
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
  tar xvfz /usr/local/src/ioncube_loaders_lin_x86-64.tar.gz
  mv /usr/local/src/ioncube /usr/local
  EOH
end

file "#{node['php']['ext_conf_dir']}/ioncube.ini" do
  content "zend_extension=/usr/local/ioncube/ioncube_loader_lin_" + node[:php_ioncube][:version] + ".so"
  owner "root"
  group "root"
  mode "0644"
  action :create_if_missing
  notifies :reload, resources(:service => "apache2")
end