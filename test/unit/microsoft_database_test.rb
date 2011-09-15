require 'test_helper'

class MicrosoftDatabaseTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert MicrosoftDatabase.new.valid?
  end
end
