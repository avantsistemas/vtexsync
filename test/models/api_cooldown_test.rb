require 'test_helper'

class ApiCooldownTest < ActiveSupport::TestCase
  SERVICE = 'vtex'.freeze

  test 'is not cooling down when no state was ever recorded' do
    assert_not ApiCooldown.cooling_down?(SERVICE)
    assert_equal 0, ApiCooldown.retry_after_seconds(SERVICE)
  end

  test 'reading the state never creates a row' do
    assert_no_difference -> { ApiCooldown.count } do
      ApiCooldown.cooling_down?(SERVICE)
      ApiCooldown.retry_after_seconds(SERVICE)
    end
  end

  test 'cool_down! marks the service as cooling down for the given seconds' do
    freeze_time do
      ApiCooldown.cool_down!(SERVICE, 60)

      assert ApiCooldown.cooling_down?(SERVICE)
      assert_equal 60, ApiCooldown.retry_after_seconds(SERVICE)
    end
  end

  test 'retry_after_seconds shrinks as the window elapses' do
    ApiCooldown.cool_down!(SERVICE, 60)

    travel 45.seconds do
      assert ApiCooldown.cooling_down?(SERVICE)
      assert_equal 15, ApiCooldown.retry_after_seconds(SERVICE)
    end
  end

  test 'cooldown expires once the window has fully elapsed' do
    ApiCooldown.cool_down!(SERVICE, 60)

    travel 61.seconds do
      assert_not ApiCooldown.cooling_down?(SERVICE)
      assert_equal 0, ApiCooldown.retry_after_seconds(SERVICE)
    end
  end

  test 'cool_down! reuses the single row per service instead of creating new ones' do
    ApiCooldown.cool_down!(SERVICE, 30)

    assert_difference -> { ApiCooldown.count }, 0 do
      ApiCooldown.cool_down!(SERVICE, 90)
    end

    assert_equal 1, ApiCooldown.where(name: SERVICE).count
  end

  test 'tracks cooldowns for different services independently' do
    ApiCooldown.cool_down!('vtex', 60)

    assert ApiCooldown.cooling_down?('vtex')
    assert_not ApiCooldown.cooling_down?('protheus')
  end
end
