require_relative '../test_helper'

class PropertyValueTest < Minitest::Test
  def teardown
    PropertyValue.destroy_all
  end

  def test_gid
    assert_equal 'gid://shopify/Taxonomy/Attribute/1/1', PropertyValue.new(id: '1-1', name: 'Foo').gid
  end

  def test_default_ordering_places_other_at_end
    red = PropertyValue.create(id: '1-1', name: 'Red')
    zoo = PropertyValue.create(id: '1-2', name: 'Zoo')
    other = PropertyValue.create(id: '1-3', name: 'Other')

    assert_equal [red, zoo, other], PropertyValue.all.to_a
  end
end