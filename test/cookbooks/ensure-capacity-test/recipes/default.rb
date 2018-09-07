ensure_capacity 'test1' do
  scale_threshold 10
  block lambda {|| 11}
  scale_action lambda { %x(echo 'scaled!' >> /tmp/test1)}
end


ensure_capacity 'test2' do
  block lambda {|| 71}
  scale_action lambda { %x(echo 'scaled!' >> /tmp/test2)}
end

ensure_capacity 'test1' do
  scale_threshold 10
  block lambda {|| 9}
  scale_action lambda { %x(echo 'scaled!' >> /tmp/test1)}
end
