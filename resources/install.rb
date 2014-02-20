actions :install

attribute :name, :kind_of => String, :default => 'phpioncube', :name_attribute => true
attribute :arch, :kind_of => String, :default => node[:kernel][:machine]

def initialize(*args)
  super
  @action = :install
end
