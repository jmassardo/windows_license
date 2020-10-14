# Windows Activation Chef Resource

This cookbook contains a custom Chef resource that provides a simple way to activate (or rearm) Windows nodes by wrapping the `slmgr.vbs` script in a Cheffy way.

If you need to query keys for a group of nodes, consider using the [Windows Licensing Ohai plugin](https://github.com/jmassardo/ohai_ms_licensing).

## Usage

Use the `windows_license` resource to activate, clear, rearm, or provide KMS info for Windows nodes.

## Syntax

``` ruby
windows_license 'name' do
  action               Symbol # defaults to :activate if not specified
  product_key          String # Key must be a xxxxx-xxxxx-xxxxx-xxxxx-xxxxx format
  skms_server          String # Optional
  skms_port            Integer # Optional. Defaults to 1688 if skms_server value is specified.
  skms_domain          String # Optional
end
```

where:

* `windows_license` is the resource.
* `name` is the name given to the resource block.
* `action` identifies which steps Chef Infra Client will take to bring the node into the desired state.
* `action`, `product_key`, `skms_server`, `skms_port`, and `skms_domain` are the properties available to this resource.

## Actions

The `windows_license` resource has the following actions:

`:activate`

Default. Installs product key if specified and attempts to activate system. (e.g. `slmgr.vbs /ato`)

`:clear`

Clear product key from system.

`:rearm`

Attempt to extend the activation window

## Properties

The `windows_license` resource has the following properties:

`product_key`

**Ruby Type:** String

Optional. Windows Product Key. Must use xxxxx-xxxxx-xxxxx-xxxxx-xxxxx format

`skms_server`

**Ruby Type:** String

Optional. KMS Server hostname or FQDN

`skms_port`

**Ruby Type:** Integer | **Default Value:** 1688

Optional. Only required if `skms_server` property is specified. This is the TCP port number for the KMS server.

`skms_domain`

**Ruby Type:** String

Optional. KMS domain if KMS records exist in different domain/forest

## Examples

Attempt to activate using KMS:

``` ruby
windows_license 'Activate Windows' do
  action :activate
end
```

Attempt to activate using a product key:

``` ruby
windows_license 'Activate Windows' do
  action :activate
  product_key node['windows_license']['product_key']
end
```
