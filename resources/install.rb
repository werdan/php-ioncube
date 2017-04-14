actions :install

property :arch, String, default: node['kernel']['machine']

def initialize(*args)
  super
  @action = :install
end
