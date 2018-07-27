require 'yaml'
config = YAML.load_file(ARGV.first || 'config.yml')

atm_menu = <<MENU_END
  Please Choose From the Following Options:
  1. Display Balance
  2. Withdraw
  3. Log Out

  >
MENU_END
atm_asks_account = "Please Enter Your Account Number:\n> "
atm_asks_password = "Enter Your Password:\n>  "

root = File.expand_path('.', __dir__)
require File.join(root, %w[lib atm])

atm = Atm.new(config)

loop do
  if atm.user_logged?
    print atm_menu
    print atm.dispatch(gets)
  else
    print atm_asks_account
    account = gets.to_i
    print atm_asks_password
    passw = gets
    atm.login(account, passw)
  end
end
