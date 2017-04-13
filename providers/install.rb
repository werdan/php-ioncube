action :install do
  arch_string = case node['kernel']['machine']
                when 'x86_64'
                  'x86-64'
                when /i[36]86/
                  'x86'
                else
                  node['kernel']['machine']
                end

  Chef::Log.debug("Selected #{arch_string} arch")

  remote_file "/usr/local/src/ioncube_loaders_lin_#{arch_string}.tar.gz" do
    source "http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_#{arch_string}.tar.gz"
    action :create_if_missing
    notifies :run, 'script[Extract_ioncube_php]', :immediately
  end

  script 'Extract_ioncube_php' do
    interpreter 'bash'
    user 'root'
    cwd '/usr/local/src/'
    action :nothing
    code <<-EOH
    tar xvfz /usr/local/src/ioncube_loaders_lin_#{arch_string}.tar.gz
    mv /usr/local/src/ioncube /usr/local
    EOH
  end

  ruby_block 'Determine php version' do
    block do
      php_version_output = shell_out!('php --version').stdout
      php_version = php_version_output.match(/PHP ([0-9]+\.[0-9]+)\.[0-9]+/)[1]
      Chef::Log.info("Detected PHP version #{php_version}")
      ioncube_file_resource = resource_collection.find(file: "#{node['php']['ext_conf_dir']}/ioncube.ini")
      ioncube_file_resource.content "; priority=00\nzend_extension=/usr/local/ioncube/ioncube_loader_lin_" + php_version + ".so\n"
    end
    only_if { node['php_ioncube']['version'] == '' }
  end

  file "#{node['php']['ext_conf_dir']}/ioncube.ini" do
    content "; priority=00\nzend_extension=/usr/local/ioncube/ioncube_loader_lin_" + node['php_ioncube']['version'] + ".so\n"
  end

  if new_resource.updated_by_last_action?
    Chef::Log.info('new_resource.updated_by_last_action is true')
  else
    Chef::Log.info('new_resource.updated_by_last_action is false')
  end
end
