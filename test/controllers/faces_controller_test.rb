# frozen_string_literal: true

require "test_helper"

class FacesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tray = trays(:one)
    @cube = cubes(:one)
    @face = faces(:one)
  end

  def face_params
    {
      position: @face.position,
      text: @face.text
    }
  end

  test "should get index" do
    get tray_cube_faces_url(@tray, @cube)
    assert_response :success
  end

  test "should get new" do
    get new_tray_cube_face_url(@tray, @cube)
    assert_response :success
  end

  test "should create face" do
    assert_difference("Face.count") do
      post tray_cube_faces_url(@tray, @cube), params: { face: face_params }
    end

    assert_redirected_to [@tray, @cube, Face.last]
  end

  test "should show face" do
    get tray_cube_face_url(@tray, @cube, @face)
    assert_response :success
  end

  test "should get edit" do
    get edit_tray_cube_face_url(@tray, @cube, @face)
    assert_response :success
  end

  test "should update face" do
    patch tray_cube_face_url(@tray, @cube, @face), params: { face: face_params }
    assert_redirected_to [@tray, @cube, @face]
  end

  test "should destroy face" do
    assert_difference("Face.count", -1) do
      delete tray_cube_face_url(@tray, @cube, @face)
    end

    assert_redirected_to tray_cube_faces_url(@tray, @cube)
  end
end
