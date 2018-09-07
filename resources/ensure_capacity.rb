property :scale_threshold, [Float, Integer], default: 70
# The function to be evaluated
property :block, Proc, required: true
# The function to invoked if the scale threshold is violated
property :scale_action, Proc, required: true

resource_name :ensure_capacity

# Evaluates the function :block and compares it to :scale_threshold
# If the return value is greater than :scale_threshold then
# :scale_action is invoked

action :run do

  value = new_resource.block.call

  if (value > new_resource.scale_threshold)
    Chef::Log.info("Capacity is insufficient: #{value} > #{new_resource.scale_threshold}!")
    new_resource.scale_action.call
  end

end
