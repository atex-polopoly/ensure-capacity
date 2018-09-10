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
            .select{ |result| result['value'][1]}
            .sum
  server_count = data['data']['result'].length
  CPU_LOAD.new((total/server_count).round, server_count)
end

def dig(hash, *path)
  path.inject hash do |location, key|
    location.respond_to?(:keys) ? location[key] : nil
  end
end
