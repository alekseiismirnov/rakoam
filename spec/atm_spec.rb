require 'atm'
require 'yaml'
config = YAML.load_file('config.yml')
raise 'rspec: ATM config is nil' if config.nil?

describe '#login' do
  before(:each) do
    @atm = Atm.new(config)
  end
  it 'allows existing user to login' do
    expect(@atm.login(3321, 'mypass')).to eq('Hello, Volodymyr!')
  end
  it 'rejects wrong login' do
    message = @atm.login(321, 'mypass')
    expect(message).to eq('ERROR: ACCOUNT NUMBER AND PASSWORD DON\'T MATCH')
  end
  it 'rejects wrong password' do
    message = @atm.login('Volodymyr', 'shmass')
    expect(message).to eq('ERROR: ACCOUNT NUMBER AND PASSWORD DON\'T MATCH')
  end
end

describe '#user_logged?' do
  before(:each) do
    @atm = Atm.new(config)
  end
  it 'true on if somebody logged' do
    @atm.login(3321, 'mypass')
    expect(@atm.user_logged?).to be_truthy
  end
  it 'false on if nobody logged' do
    @atm.login('jam', 'mypass')
    expect(@atm.user_logged?).to be_falsey
  end
end
