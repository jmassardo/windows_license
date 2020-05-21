resource_name :windows_license

default_action :activate

property :product_key,
          String,
          validation_message: 'Version must be a xxxxx-xxxxx-xxxxx-xxxxx-xxxxx format String type',
          regex: [/^.{5}[-].{5}[-].{5}[-].{5}[-].{5}/]

action :activate do
  if license_status != 'Activated'
    install_product_key unless !new_resource.product_key.nil?
    activate_key
  else
    Chef::Log.info 'Windows is already activated'
  end
end

action_class do
  def activate_key
    Chef::Log.info 'Attempting to activate Windows'
    cmd = shell_out('cscript %windir%\system32\slmgr.vbs -ato')
    Chef::Log.fatal 'Error during activation' unless cmd.exitstatus == 0
  end

  def install_product_key
    Chef::Log.info 'Installing Windows Product Key'
    cmd = shell_out("cscript %windir%\\system32\\slmgr.vbs -ipk #{new_resource.product_key}")
    Chef::Log.fatal 'Error during key installation' unless cmd.exitstatus == 0
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
