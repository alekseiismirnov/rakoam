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

describe '#dispatch' do
  before(:each) do
    config = YAML.load_file('config.yml')
    @atm = Atm.new(config)
    @atm.login(5922, 'ho#ll_§1')
  end

  describe '1 balance' do
    it 'reports balance of logged user' do
      expect(@atm.dispatch(1)).to eq('Your Current Balance is ₴5301')
    end
  end

  describe '3 logout' do
    it 'no user_logged?' do
      @atm.dispatch(3)
      expect(@atm.user_logged?).to be_falsey
    end
  end

  describe '3 withdraw' do
    it 'when insufficient fonds' do
      expect(@atm.withdraw(1_000_000)).to eq('ERROR: INSUFFICIENT FUNDS!! PLEASE ENTER A DIFFERENT AMOUNT.')
    end
    it 'when not enough cash' do
      expect(@atm.withdraw(5_000)).to eq('ERROR: THE MAXIMUM AMOUNT AVAILABLE IN THIS ATM IS ₴337.')
    end
    it 'when enough' do
      expect(@atm.withdraw(23)).to eq('Your Current Balance is ₴5278')
    end 
  end
end
