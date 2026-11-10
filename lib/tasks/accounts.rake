namespace :wheelhouse do
  desc "Give every account a new random password, print each one once, and sign every account out"
  task rotate_passwords: :environment do
    # The seed writes passwords that are published in the README. In production they are replaced,
    # after the seed has loaded, by running this task through Kamal (see docs/deployment.md). The new
    # passwords are printed only to the terminal that runs it: copy them to a password manager.
    rows = User.order(:email_address).map do |user|
      password = SecureRandom.alphanumeric(20)
      user.update!(password: password, password_confirmation: password)
      user.sessions.destroy_all
      [ user.email_address, user.role, password ]
    end

    width = rows.map { |email, _, _| email.length }.max.to_i
    rows.each { |email, role, password| puts "#{email.ljust(width)}  #{role.to_s.ljust(8)}  #{password}" }
    puts "#{rows.size} accounts have a new password; every session was closed."
  end
end
