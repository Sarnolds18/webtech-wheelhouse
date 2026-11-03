require "test_helper"

class RepairsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:counter)) }

  test "a new repair is taken in by the account signed in, whatever the request sends" do
    post repairs_path, params: { repair: { bike_id: bikes(:javiera_marlin).id, state: "received",
                                           received_at: Time.current, promised_on: 2.days.from_now.to_date,
                                           taken_in_by_id: users(:one).id } }

    repair = Repair.order(:id).last
    assert_redirected_to repair_path(repair)
    assert_equal users(:counter), repair.taken_in_by
  end

  test "editing a repair does not change who took it in" do
    repair = repairs(:received)
    repair.update!(taken_in_by: users(:one))

    patch repair_path(repair), params: { repair: { state: "diagnosed", taken_in_by_id: users(:counter).id } }

    assert_redirected_to repair_path(repair)
    assert_equal users(:one), repair.reload.taken_in_by
  end

  test "the repair's page shows who took it in" do
    repair = repairs(:received)
    repair.update!(taken_in_by: users(:one))

    get repair_path(repair)

    assert_match users(:one).display_name, response.body
  end

  test "a visitor is sent to sign in, never shown the 403 page" do
    sign_out

    get repairs_path
    assert_redirected_to new_session_path

    delete repair_path(repairs(:received))
    assert_redirected_to new_session_path
  end

  # --- Who may do what ---------------------------------------------------------

  test "a mechanic's index lists only their own repairs, also when filtered" do
    sign_in_as(users(:fuentes))

    get repairs_path
    assert_response :success
    assert_select "a[href=?]", repair_path(repairs(:fuentes_open))
    assert_select "a[href=?]", repair_path(repairs(:collected))
    assert_select "a[href=?]", repair_path(repairs(:rojas_open)), count: 0
    assert_select "a[href=?]", repair_path(repairs(:received)), count: 0

    get repairs_path(state: "diagnosed")
    assert_select "a[href=?]", repair_path(repairs(:rojas_open)), count: 0

    get repairs_path(overdue: "1")
    assert_select "a[href=?]", repair_path(repairs(:rojas_open)), count: 0
  end

  test "the counter's filters are chained on every repair" do
    get repairs_path(overdue: "1")

    assert_select "a[href=?]", repair_path(repairs(:rojas_open))
    assert_select "a[href=?]", repair_path(repairs(:fuentes_open)), count: 0
  end

  test "a mechanic who changes the id in the URL gets 403 for the page and the edit form" do
    sign_in_as(users(:fuentes))

    get repair_path(repairs(:rojas_open))
    assert_response :forbidden
    assert_match "not allowed", response.body

    get edit_repair_path(repairs(:rojas_open))
    assert_response :forbidden
  end

  test "a mechanic's repair page shows the bike and customer without links" do
    sign_in_as(users(:fuentes))

    get repair_path(repairs(:fuentes_open))

    assert_response :success
    assert_match bikes(:javiera_marlin).serial_number, response.body
    assert_select "a[href=?]", bike_path(bikes(:javiera_marlin)), count: 0
    assert_select "a[href=?]", customer_path(customers(:javiera)), count: 0
    assert_select "a[href=?]", edit_repair_path(repairs(:fuentes_open))
    assert_select "form[action=?] input[value=delete]", repair_path(repairs(:fuentes_open)), count: 0
  end

  test "a mechanic's form has only the state, the diagnosis and the photos" do
    sign_in_as(users(:fuentes))

    get edit_repair_path(repairs(:fuentes_open))

    assert_response :success
    assert_select "select[name=?]", "repair[state]"
    assert_select "input[name=?]", "repair[diagnosis]"
    assert_select "input[name=?]", "repair[photos][]"
    assert_select "[name=?]", "repair[mechanic_id]", count: 0
    assert_select "[name=?]", "repair[promised_on]", count: 0
    assert_select "[name^=?]", "repair[repair_services_attributes]", count: 0
  end

  test "a field outside a mechanic's list, added by hand, is dropped and the rest is saved" do
    sign_in_as(users(:fuentes))
    repair = repairs(:fuentes_open)
    line = repair_services(:fuentes_open_tube)

    patch repair_path(repair), params: { repair: {
      state: "finished", mechanic_id: mechanics(:rojas).id, promised_on: 1.year.from_now.to_date,
      repair_services_attributes: [ { id: line.id, charged_price: 1 } ]
    } }

    assert_redirected_to repair_path(repair)
    repair.reload
    assert_equal "finished", repair.state
    assert_equal mechanics(:fuentes), repair.mechanic
    assert_equal 2.days.from_now.to_date, repair.promised_on
    assert_equal 8000, line.reload.charged_price
  end

  test "a mechanic can't take a repair in or edit another's" do
    sign_in_as(users(:fuentes))

    get new_repair_path
    assert_response :forbidden

    assert_no_difference "Repair.count" do
      post repairs_path, params: { repair: { bike_id: bikes(:javiera_marlin).id, state: "received",
                                             received_at: Time.current, promised_on: 2.days.from_now.to_date } }
    end
    assert_response :forbidden

    patch repair_path(repairs(:rojas_open)), params: { repair: { state: "finished" } }
    assert_response :forbidden
    assert_equal "diagnosed", repairs(:rojas_open).reload.state
  end

  test "a handed-back repair is edited only by the owner" do
    repair = repairs(:collected)

    patch repair_path(repair), params: { repair: { promised_on: Date.current } }
    assert_response :forbidden
    assert_equal 7.days.ago.to_date, repair.reload.promised_on

    sign_in_as(users(:one))
    patch repair_path(repair), params: { repair: { quoted_amount: 9000 } }
    assert_redirected_to repair_path(repair)
    assert_equal 9000, repair.reload.quoted_amount
  end

  test "only the owner deletes a repair; a refused delete leaves it" do
    assert_no_difference "Repair.count" do
      delete repair_path(repairs(:received))
    end
    assert_response :forbidden

    sign_in_as(users(:one))
    assert_difference "Repair.count", -1 do
      delete repair_path(repairs(:received))
    end
  end

  test "an account with no member of the staff reads no repair" do
    sign_in_as(users(:two))

    get repairs_path
    assert_response :success
    assert_match "No repairs on record yet.", response.body

    get repair_path(repairs(:received))
    assert_response :forbidden
  end

  test "another mechanic's staff page lists none of the colleague's repairs" do
    sign_in_as(users(:fuentes))

    get mechanic_path(mechanics(:rojas))

    assert_response :success
    assert_select "a[href=?]", repair_path(repairs(:rojas_open)), count: 0
  end
end
