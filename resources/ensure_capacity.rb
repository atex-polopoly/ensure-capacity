property :scale_threshold, [Float, Integer], default: 70
property :prometheus_api_address, String, required: true

resource_name :ensure_capacity

action :run do

  Aws.config[:region] = aws_region

  tags = get_ec2_tags
  cpu_load = get_cpu_load(prometheus_api_address,
               tags['Layer'],
               tags['Environment'],
               tags['Group'])

  puts "CPU average: #{cpu_load.average}"
  above_capacity = cpu_load.average * cpu_load.server_count/(cpu_load.server_count - 1) > scale_threshold


  scale_up 'auto scaling group' do
    not_if { node['has_scaled_up']}
    only_if { true || above_capacity }
  end

  ruby_block 'set scaled up' do
    block do
      node.default['has_scaled_up'] = true
    end
    not_if { node['has_scaled_up']}
    only_if { above_capacity }
  end

end
