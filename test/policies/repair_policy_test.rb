require "test_helper"

# The rules of docs/permissions.md for repairs, asked of the policy and its scope directly.
class RepairPolicyTest < ActiveSupport::TestCase
  def policy(user, repair) = RepairPolicy.new(user, repair)
  def scope(user) = RepairPolicy::Scope.new(user, Repair).resolve

  test "owner and counter read every repair; a mechanic only the ones assigned to them" do
    assert_equal Repair.count, scope(users(:one)).count
    assert_equal Repair.count, scope(users(:counter)).count
    assert_equal Repair.where(mechanic: mechanics(:fuentes)).to_a.sort, scope(users(:fuentes)).to_a.sort
  end

  test "a mechanic account with no member of the staff reads no repair" do
    assert_empty scope(users(:two))
    Repair.find_each { |repair| assert_not policy(users(:two), repair).show? }
  end

  test "the scope and show? give the same answer for every account and every repair" do
    User.find_each do |user|
      readable = scope(user).to_a
      Repair.find_each do |repair|
        assert_equal readable.include?(repair), policy(user, repair).show?, "#{user.email_address}, repair #{repair.id}"
      end
    end
  end

  test "taking a repair in: owner and counter only" do
    assert policy(users(:one), Repair.new).create?
    assert policy(users(:counter), Repair.new).create?
    assert_not policy(users(:fuentes), Repair.new).create?
    assert_not policy(nil, Repair.new).create?
  end

  test "editing: a handed-back repair only by the owner" do
    collected = repairs(:collected) # assigned to Fuentes
    assert policy(users(:one), collected).update?
    assert_not policy(users(:counter), collected).update?
    assert_not policy(users(:fuentes), collected).update?
  end

  test "editing: a mechanic only their own repairs" do
    assert policy(users(:fuentes), repairs(:fuentes_open)).update?
    assert_not policy(users(:fuentes), repairs(:rojas_open)).update?
    assert_not policy(users(:fuentes), repairs(:received)).update? # no mechanic yet
    assert policy(users(:counter), repairs(:rojas_open)).update?
  end

  test "deleting: the owner only" do
    assert policy(users(:one), repairs(:received)).destroy?
    assert_not policy(users(:counter), repairs(:received)).destroy?
    assert_not policy(users(:fuentes), repairs(:fuentes_open)).destroy?
  end

  test "a mechanic writes the state, the diagnosis and new photos, nothing else" do
    assert_equal [ :state, :diagnosis, { photos: [] } ], policy(users(:fuentes), repairs(:fuentes_open)).permitted_attributes
    assert policy(users(:counter), repairs(:received)).permitted_attribute?(:mechanic_id)
    assert_not policy(users(:fuentes), repairs(:fuentes_open)).permitted_attribute?(:repair_services_attributes)
  end

  test "removing a photo: whoever edits every field, never a mechanic" do
    assert policy(users(:counter), repairs(:fuentes_open)).destroy_photo?
    assert_not policy(users(:fuentes), repairs(:fuentes_open)).destroy_photo?
  end
end
