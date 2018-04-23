require 'test_helper'

class TraysControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tray = trays(:one)
  end

  test "should get index" do
    get trays_url
    assert_response :success
  end

  test "should get new" do
    get new_tray_url
    assert_response :success
  end

  test "should create tray" do
    assert_difference('Tray.count') do
      post trays_url, params: { tray: { name: @tray.name, slug: @tray.slug } }
    end

    assert_redirected_to tray_url(Tray.last)
  end

  test "should show tray" do
    get tray_url(@tray)
    assert_response :success
  end

  test "should get edit" do
    get edit_tray_url(@tray)
    assert_response :success
  end

  test "should update tray" do
    patch tray_url(@tray), params: { tray: { name: @tray.name, slug: @tray.slug } }
    assert_redirected_to tray_url(@tray)
  end

  test "should destroy tray" do
    assert_difference('Tray.count', -1) do
      delete tray_url(@tray)
    end

    assert_redirected_to trays_url
  end
end
