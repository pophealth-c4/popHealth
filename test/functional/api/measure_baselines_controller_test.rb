require 'test_helper'
include Devise::TestHelpers
  module Api
  class MeasureBaselinesControllerTest < ActionController::TestCase

    setup do
      dump_database
      collection_fixtures 'measures', 'records', 'users'
      load_measure_baselines
      @user = User.where({email: "admin@test.com"}).first
    end

    test "GET returns latest baseline" do
      sign_in @user
      get :show, :id => '0013'
      assert_response :success
      body = response.body
      json = JSON.parse(body)
      assert_equal "0013", json["measure_id"]
      assert_equal "75%", json["result"]["value"]
    end

    test "GET returns matched start/end dates" do
      sign_in @user
      get :show, :id => '0032', :start_date => 1419984000, :end_date => 1451520000
      assert_response :success
      body = response.body
      json = JSON.parse(body)
      assert_equal "0032", json["measure_id"]
      assert_equal "72%", json["result"]["value"]
    end

    test "GET returns contained start/end dates" do
      sign_in @user
      # Looking from 9/1/14 - 12/1/14.
      get :show, :id => '0032', :start_date => 1409529600, :end_date => 1417392000
      assert_response :success
      body = response.body
      json = JSON.parse(body)
      assert_equal "0032", json["measure_id"]
      assert_equal "73%", json["result"]["value"]
    end

    test "GET does not return if range is outside baseline period" do
      sign_in @user
      # Looking from 9/1/15 - 1/1/16.
      get :show, :id => '0032', :start_date => 1441065600, :end_date => 1451606400
      assert_response :success
      body = response.body
      assert_equal "{}", body
    end

    test "GET will search using source id" do
      sign_in @user
      get :show, :id => '0013', :source_id => MeasureBaselineSource.last
      assert_response :success
      body = response.body
      json = JSON.parse(body)
      assert_equal "0013", json["measure_id"]
      assert_equal "100%", json["result"]["value"]
    end

    test "GET returns nil for measure without baseline" do
      sign_in @user
      get :show, :id => '0015'
      assert_response :success
      body = response.body
      assert_equal "{}", body
    end
  end
end
