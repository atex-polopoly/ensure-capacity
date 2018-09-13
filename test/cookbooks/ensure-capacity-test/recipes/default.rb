

ensure_capacity 'test' do
  prometheus_api_address "#{node['prometheus']['host']}:#{node['prometheus']['api']['port']}#{node['prometheus']['api']['query_path']}"
  action :nothing
end.run_action :run # Run in compile phase
