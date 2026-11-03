require "test_helper"

# The rules of docs/permissions.md for the other resources with pages.
class ResourcePoliciesTest < ActiveSupport::TestCase
  ACTIONS = %i[ index? show? new? create? edit? update? destroy? ].freeze

  def allowed(policy_class, user, record)
    policy = policy_class.new(user, record)
    ACTIONS.select { |action| policy.public_send(action) }
  end

  test "the base policy refuses everything and its scope returns nothing" do
    policy = ApplicationPolicy.new(users(:one), Repair.new)
    ACTIONS.each { |action| assert_not policy.public_send(action), action }
    assert_empty ApplicationPolicy::Scope.new(users(:one), Repair).resolve
  end

  test "services: everybody reads, the owner writes" do
    assert_equal ACTIONS, allowed(ServicePolicy, users(:one), services(:tube))
    [ users(:counter), users(:fuentes), nil ].each do |user|
      assert_equal %i[ index? show? ], allowed(ServicePolicy, user, services(:tube))
    end
  end

  test "staff: every account reads, the owner writes" do
    assert_equal ACTIONS, allowed(MechanicPolicy, users(:one), mechanics(:rojas))
    assert_equal %i[ index? show? ], allowed(MechanicPolicy, users(:counter), mechanics(:rojas))
    assert_equal %i[ index? show? ], allowed(MechanicPolicy, users(:fuentes), mechanics(:rojas))
  end

  test "customers and bikes: owner everything, counter all but delete, mechanic nothing" do
    { CustomerPolicy => customers(:javiera), BikePolicy => bikes(:javiera_marlin) }.each do |policy_class, record|
      assert_equal ACTIONS, allowed(policy_class, users(:one), record)
      assert_equal ACTIONS - %i[ destroy? ], allowed(policy_class, users(:counter), record)
      assert_empty allowed(policy_class, users(:fuentes), record)
      assert_empty allowed(policy_class, users(:two), record)
    end

    assert_empty CustomerPolicy::Scope.new(users(:fuentes), Customer).resolve
    assert_empty BikePolicy::Scope.new(users(:fuentes), Bike).resolve
  end
end
