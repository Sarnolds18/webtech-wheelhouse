require "test_helper"

class WelcomeMailerTest < ActionMailer::TestCase
  test "welcome names the account and links to the sign-in page, in both parts" do
    user = users(:two)
    mail = WelcomeMailer.welcome(user)

    assert_equal [ user.email_address ], mail.to
    assert_match "Wheelhouse", mail.subject

    [ mail.text_part, mail.html_part ].each do |part|
      assert_match user.email_address, part.body.to_s
      assert_match %r{https?://\S+/session/new}, part.body.to_s
      assert_match "Wheelhouse", part.body.to_s
    end
  end
end
