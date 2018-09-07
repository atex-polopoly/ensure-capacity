describe file('/tmp/test1') do
  it { should exist}
  it { should be_file }
  its('content') { should include 'scaled!' }
end

describe file('/tmp/test2') do
  it { should exist}
  it { should be_file }
  its('content') { should include 'scaled!' }
end

describe file('/tmp/test3') do
  it { should_not exist}
end
