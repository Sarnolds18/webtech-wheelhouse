require "test_helper"
require "rake"

class RotatePasswordsTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks unless Rake::Task.task_defined?("wheelhouse:rotate_passwords")
    Rake::Task["wheelhouse:rotate_passwords"].reenable
  end

  test "every account gets a new password, printed once, and every session is closed" do
    user = users(:one)
    old_digest = user.password_digest
    user.sessions.create!
    output, = capture_io { Rake::Task["wheelhouse:rotate_passwords"].invoke }

    line = output.lines.find { |l| l.start_with?(user.email_address) }
    new_password = line.split.last
    assert_equal 20, new_password.length
    assert_not_equal old_digest, user.reload.password_digest
    assert user.authenticate(new_password)
    assert_equal User.count, output.lines.count { |l| l.include?("@") }
    assert_equal 0, Session.count
  end
end
