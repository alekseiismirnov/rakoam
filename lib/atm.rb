# ATM API provision.
# With all user data inside.
class Atm
  @user_welcome = 'Hello, %<username>s!'
  @login_fail = 'ERROR: ACCOUNT NUMBER AND PASSWORD DON\'T MATCH'
  @withdraw_prompt = "Enter Amount You Wish to Withdraw \n> "
  @balance_message = 'Your Current Balance is ₴%<balance>i'
  @insufficient_funds = 'ERROR: INSUFFICIENT FUNDS!! PLEASE ENTER A DIFFERENT AMOUNT.'
  @not_enough_cash = 'ERROR: THE MAXIMUM AMOUNT AVAILABLE IN THIS ATM IS ₴%<cash>i.'
  @no_such_bills = 'ERROR: THE AMOUNT YOU REQUESTED CANNOT BE COMPOSED FROM BILLS AVAILABLE IN THIS ATM.'
  class << self
    attr_reader :user_welcome, :login_fail, :withdraw_prompt, :balance_message
    attr_reader :insufficient_funds, :not_enough_cash, :no_such_bills
  end

  def initialize(config)
    raise 'ATM config is nil' if config.nil?
    @config = config.clone
    @banknotes = config['banknotes'].flat_map { |nom, n| Array.new(n, nom) }
  end

  def login(number, pass)
    account = @config['accounts'][number]
    if account.nil?
      self.class.login_fail
    elsif pass != account['password']
      self.class.login_fail
    else
      @account_number = number
      format(self.class.user_welcome, username: account['name'])
    end
  end

  def user_logged?
    !@account_number.nil?
  end

  def dispatch(command)
    case command
    when 1
      balance
    when 2
      print self.class.withdraw_prompt
      withdraw(gets.to_i)
    when 3
      logout
    end
  end

  def withdraw(amount)
    raise 'withdraw called with no user logged' unless user_logged?
    if amount > balance_get
      self.class.insufficient_funds
    elsif amount > cash
      format(self.class.not_enough_cash, cash: cash)
    else
      giveaway_bills = pick_banknotes(amount)
      if giveaway_bills.nil?
         self.class.no_such_bills
      else
        @banknotes -= giveaway_bills
        balance_set(balance_get - amount)
        balance
      end
    end
  end

  private

  def balance
    raise 'balance() called with no user logged' unless user_logged?
    format(self.class.balance_message, balance: balance_get)
  end

  def logout
    @account_number = nil
  end

  def balance_set(amount)
    raise 'balance_set called with no user logged' unless user_logged?
    @config['accounts'][@account_number]['balance'] = amount
  end

  def balance_get
    raise 'balance_get called with no user logged' unless user_logged?
    @config['accounts'][@account_number]['balance']
  end

  def cash
    @banknotes.inject(0, :+)
  end

  def pick_banknotes(amount)
    ab = @banknotes.select { |b| b <= amount } # quick and dirty reduce
    combs = (1..ab.length).map { |i| ab.combination(i) } # list of enumerators
    combs = combs.lazy.flat_map(&:lazy) # flat enumerator
    combs.detect { |bs| bs.inject(0, :+) == amount } # voila
  end
end
