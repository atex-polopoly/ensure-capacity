require 'net/http'
require 'uri'

CPU_LOAD = Struct.new(:average, :server_count)

def get_cpu_load(server, layer, environment, group)

  query = '100 - (avg by (instance) (irate(node_cpu{job=~"' + layer +
          '[\\\d]*-' + environment + '-' + group + '",mode="idle"}[5m])) * 100)'
  escaped = CGI.escape query
  uri = URI.parse "#{server}?query=#{escaped}"
  data = Net::HTTP.get uri
  data = JSON.parse data
  # Check that response is valid, crash otherwise
  total = data['data']['result']
            .map{ |result| result['value'][1].to_f }
            .each { |value| puts value; value }
            .reduce(0, :+)
  server_count = data['data']['result'].length
  CPU_LOAD.new((total/server_count).round, server_count)
end

def dig(hash, *path)
  path.inject hash do |location, key|
    location.respond_to?(:keys) ? location[key] : nil
  end
end

def _get_ec2_client
  @_ec2_client ||= Aws::EC2::Client.new
end

def aws_region
  @_aws_az = Net::HTTP.get(URI.parse('http://169.254.169.254/latest/meta-data/placement/availability-zone/')) if @_aws_az.nil?
  # i.e. eu-west-1b -> eu-west-1
  @_aws_az[0..-2]
end

def instance_id
  @_instance_id = Net::HTTP.get(URI.parse('http://169.254.169.254/latest/meta-data/instance-id')) if @_instance_id.nil?
  @_instance_id
end

def get_ec2_tags()

  @_instance_tags ||= _get_ec2_client
    .describe_tags(
      filters: [
        {
          :name => 'resource-id',
          :values => [instance_id]
        }])
    .to_h[:tags]
    .each { |hsh| hsh.delete :resource_id }
    .each { |hsh| hsh.delete :resource_type }
    .map(&:values)
    .to_h
    .select { |key,_|  %w(Group Environment Layer).include? key }
end
