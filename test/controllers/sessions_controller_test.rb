require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = User.take }

  test "new" do
    get new_session_path
    assert_response :success
  end

  test "create with valid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "password1234" }

    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "create with invalid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "wrong" }

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
  end

  test "an unknown email address gets the same message as a wrong password" do
    post session_path, params: { email_address: @user.email_address, password: "wrong" }
    follow_redirect!
    wrong_password = flash[:alert]

    post session_path, params: { email_address: "nobody@example.com", password: "password1234" }
    follow_redirect!
    assert_equal wrong_password, flash[:alert]
  end

  test "destroy" do
    sign_in_as(User.take)

    delete session_path

    assert_redirected_to new_session_path
    assert_empty cookies[:session_id]
  end
end
