#
# Cookbook:: windows_license
# Recipe:: default
#
# Copyright:: 2020, The Authors, All Rights Reserved.
windows_license 'Activate Windows' do
  action :activate
  product_key node['windows_license']['product_key']
end
