require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "new" do
    get new_registration_path
    assert_response :success
  end

  test "create makes an account with the default role, signs it in and sends the welcome email later" do
    assert_difference "User.count", 1 do
      assert_enqueued_emails 1 do
        post registration_path, params: { user: { email_address: "Ana@Wheelhouse.cl", password: "a-long-password",
                                                  password_confirmation: "a-long-password" } }
      end
    end

    assert_redirected_to root_path
    assert cookies[:session_id]
    assert User.find_by!(email_address: "ana@wheelhouse.cl").role_mechanic?
  end

  test "create ignores a role and a member of the staff written by hand" do
    post registration_path, params: { user: { email_address: "ana@wheelhouse.cl", password: "a-long-password",
                                              password_confirmation: "a-long-password",
                                              role: "owner", mechanic_id: mechanics(:vidal).id } }

    user = User.find_by!(email_address: "ana@wheelhouse.cl")
    assert user.role_mechanic?
    assert_nil user.mechanic
  end

  test "a refused sign-up answers 422, keeps the email, empties the passwords and sends nothing" do
    assert_no_difference "User.count" do
      assert_no_enqueued_emails do
        post registration_path, params: { user: { email_address: "ana@wheelhouse.cl", password: "short",
                                                  password_confirmation: "short" } }
      end
    end

    assert_response :unprocessable_entity
    assert_select "input[name='user[email_address]'][value='ana@wheelhouse.cl']"
    assert_select "input[name='user[password]']:not([value])"
    assert_match "is too short (minimum is #{User::PASSWORD_MINIMUM_LENGTH} characters)", response.body
    assert_nil cookies[:session_id]
  end
end
