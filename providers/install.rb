use_inline_resources if defined?(use_inline_resources)

action :install do

  case run_context.node[:kernel][:machine]
  when 'x86_64'
    arch_string = 'x86-64'
  when /i[36]86/
    arch_string = 'x86'
  else
    arch_string = run_context.node[:kernel][:machine]
  end

  Chef::Log.debug("case selected #{arch_string}")

  remote_file "/usr/local/src/ioncube_loaders_lin_#{arch_string}.tar.gz" do
    source "http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_#{arch_string}.tar.gz"
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
    tar xvfz /usr/local/src/ioncube_loaders_lin_#{arch_string}.tar.gz
    mv /usr/local/src/ioncube /usr/local
    EOH
  end

  ruby_block "determine php version" do
    block do
      php_version_output = `php --version`
      php_version = php_version_output.match(/PHP ([0-9]+\.[0-9]+)\.[0-9]+/)[1]
      Chef::Log.info("detected PHP version #{php_version}")
      ioncube_file_resource = run_context.resource_collection.find(:file => "#{run_context.node[:php][:ext_conf_dir]}/ioncube.ini")
      ioncube_file_resource.content "zend_extension=/usr/local/ioncube/ioncube_loader_lin_" + php_version + ".so\n"
    end
    only_if { run_context.node[:php_ioncube][:version] == '' }
  end

  file "#{run_context.node[:php][:ext_conf_dir]}/ioncube.ini" do
    content "zend_extension=/usr/local/ioncube/ioncube_loader_lin_" + run_context.node[:php_ioncube][:version] + ".so\n"  # dynamically defined during convergence in above ruby_block
    owner "root"
    group "root"
    mode "0644"
    action :create
  end

  if new_resource.updated_by_last_action?
    Chef::Log.info("new_resource.updated_by_last_action is true")
  else
    Chef::Log.info("new_resource.updated_by_last_action is false")
  end

end