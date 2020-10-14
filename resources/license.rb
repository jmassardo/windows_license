#
# Author:: James Massardo (<james@dxrf.com>)
# Copyright:: Copyright (c) James Massardo
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

resource_name :windows_license

default_action :activate

property :product_key,
          String,
          validation_message: 'Key must be a xxxxx-xxxxx-xxxxx-xxxxx-xxxxx format String type',
          regex: [/^.{5}[-].{5}[-].{5}[-].{5}[-].{5}/]

property :skms_server,
          String
property :skms_port,
          Integer,
          default: 1688
property :skms_domain,
          String

action :activate do
  if license_status != 'Activated'
    install_product_key unless !new_resource.product_key.nil?
    activate_key
  else
    Chef::Log.info 'Windows is already activated'
  end
end

action :clear do
  if license_status == 'Activated'
    clear_product_key
  else
    Chef::Log.fatal 'Windows is not activated. Can\'t clear product key'
  end
end

action :rearm do
  if license_status == 'Activated'
    rearm_product_key
  else
    Chef::Log.fatal 'Windows is not activated. Can\'t rearm license'
  end
end

action_class do
  def clear_product_key
    Chef::Log.info 'Attempting to clear the product key'
    cmd = shell_out('cscript %windir%\system32\slmgr.vbs /cpky')
    Chef::Log.fatal 'Error attempting to clear product key' unless cmd.exitstatus == 0
  end

  def rearm_product_key
    Chef::Log.info 'Attempting to rearm license'
    cmd = shell_out('cscript %windir%\system32\slmgr.vbs /rearm')
    Chef::Log.fatal 'Error attempting to rearm license' unless cmd.exitstatus == 0
  end

  def activate_key
    Chef::Log.info 'Attempting to activate Windows'
    cmd = shell_out("cscript %windir%\\system32\\slmgr.vbs #{slmgr_options}")
    Chef::Log.fatal 'Error during activation' unless cmd.exitstatus == 0
  end

  def slmgr_options
    options = ''
    options += ' /ato'
    options += " /ipk #{new_resource.product_key}" unless new_resource.product_key.nil?
    options += " /skms #{new_resource.skms_server}:#{new_resource.skms_port}" unless new_resource.skms_server.nil?
    options += " /skms-domain #{new_resource.skms_domain}" unless new_resource.skms_domain.nil?

    options
  end

  def license_status
    result = nil
    cmd = shell_out('cscript %windir%\system32\slmgr.vbs -dli')
    if cmd.exitstatus == 0
      cmd.stdout.each_line() do |line|
        case line
        when /License Status/
          data = line.split(':').each(&:lstrip!)
          result = data[1].chomp
        end
      end
      result
    end
  end
end
