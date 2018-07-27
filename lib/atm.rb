# ATM API provision.
# With all user data inside.
class Atm
  @user_welcome = 'Hello, %<username>s!'
  @login_fail = 'ERROR: ACCOUNT NUMBER AND PASSWORD DON\'T MATCH'
  class << self
    attr_reader :user_welcome, :login_fail
  end

  def initialize(config)
    raise 'ATM config is nil' if config.nil?
    @config = config.clone
    @banknotes = Hash.new(config['banknotes'])
  end

  def login(account, pass)
    @account = @config['accounts'][account]
    if @account.nil?
      self.class.login_fail
    elsif pass != @account['password']
      self.class.login_fail
    else
      format(self.class.user_welcome, username: @account['name'])
    end
  end

  def user_logged?
    !@account.nil?
  end
end
