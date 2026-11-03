require "test_helper"

# The pages of the other resources, and the parts of the app every role keeps.
class AuthorizationTest < ActionDispatch::IntegrationTest
  test "a mechanic has no access to customers or bikes, and their navbar doesn't link them" do
    sign_in_as(users(:fuentes))

    get customers_path
    assert_response :forbidden
    get bike_path(bikes(:javiera_marlin))
    assert_response :forbidden

    get root_path
    assert_response :success
    assert_select "nav a[href=?]", customers_path, count: 0
    assert_select "nav a[href=?]", bikes_path, count: 0
    assert_select "nav a[href=?]", repairs_path
    assert_select "nav a[href=?]", mechanics_path
  end

  test "the counter creates and edits customers but can't delete one" do
    sign_in_as(users(:counter))

    get customer_path(customers(:diego))
    assert_select "a[href=?]", edit_customer_path(customers(:diego))
    assert_select "form[action=?] input[value=delete]", customer_path(customers(:diego)), count: 0

    patch customer_path(customers(:diego)), params: { customer: { phone: "+56 9 0000 0000" } }
    assert_redirected_to customer_path(customers(:diego))

    assert_no_difference "Customer.count" do
      delete customer_path(customers(:diego))
    end
    assert_response :forbidden
  end

  test "only the owner changes the price list and the staff" do
    sign_in_as(users(:counter))

    get services_path
    assert_select "a[href=?]", new_service_path, count: 0

    patch service_path(services(:tube)), params: { service: { price: 1 } }
    assert_response :forbidden
    assert_equal 8000, services(:tube).reload.price

    post mechanics_path, params: { mechanic: { name: "Someone" } }
    assert_response :forbidden

    sign_in_as(users(:one))
    patch service_path(services(:tube)), params: { service: { price: 9000 } }
    assert_redirected_to service_path(services(:tube))
  end

  test "a visitor still reads the price list and is sent to sign in for the rest" do
    get services_path
    assert_response :success
    assert_select "a[href=?]", new_service_path, count: 0

    get new_service_path
    assert_redirected_to new_session_path

    get customers_path
    assert_redirected_to new_session_path
  end
end
