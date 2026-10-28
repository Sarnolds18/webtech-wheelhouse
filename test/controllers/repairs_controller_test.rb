require "test_helper"

class RepairsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:two)) }

  test "a new repair is taken in by the account signed in, whatever the request sends" do
    post repairs_path, params: { repair: { bike_id: bikes(:javiera_marlin).id, state: "received",
                                           received_at: Time.current, promised_on: 2.days.from_now.to_date,
                                           taken_in_by_id: users(:one).id } }

    repair = Repair.order(:id).last
    assert_redirected_to repair_path(repair)
    assert_equal users(:two), repair.taken_in_by
  end

  test "editing a repair does not change who took it in" do
    repair = repairs(:received)
    repair.update!(taken_in_by: users(:one))

    patch repair_path(repair), params: { repair: { state: "diagnosed", taken_in_by_id: users(:two).id } }

    assert_redirected_to repair_path(repair)
    assert_equal users(:one), repair.reload.taken_in_by
  end

  test "the repair's page shows who took it in" do
    repair = repairs(:received)
    repair.update!(taken_in_by: users(:one))

    get repair_path(repair)

    assert_match users(:one).display_name, response.body
  end

  test "a visitor is sent to sign in" do
    sign_out

    get repairs_path

    assert_redirected_to new_session_path
  end
end
