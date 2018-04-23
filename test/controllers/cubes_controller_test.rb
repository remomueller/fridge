# frozen_string_literal: true

require "test_helper"

class CubesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tray = trays(:one)
    @cube = cubes(:one)
  end

  def cube_params
    {
      cube_type: @cube.cube_type,
      description: @cube.description,
      tray_id: @cube.tray_id,
      text: @cube.text
    }
  end

  test "should get index" do
    get tray_cubes_url(@tray)
    assert_response :success
  end

  test "should get new" do
    get new_tray_cube_url(@tray)
    assert_response :success
  end

  test "should create cube" do
    assert_difference("Cube.count") do
      post tray_cubes_url(@tray), params: { cube: cube_params }
    end
    assert_redirected_to tray_cube_url(@tray, Cube.last)
  end

  test "should show cube" do
    get tray_cube_url(@tray, @cube)
    assert_response :success
  end

  test "should get edit" do
    get edit_tray_cube_url(@tray, @cube)
    assert_response :success
  end

  test "should update cube" do
    patch tray_cube_url(@tray, @cube), params: { cube: cube_params }
    assert_redirected_to [@tray, @cube]
  end

  test "should destroy cube" do
    assert_difference("Cube.count", -1) do
      delete tray_cube_url(@tray, @cube)
    end
    assert_redirected_to tray_cubes_url(@tray)
  end
end
