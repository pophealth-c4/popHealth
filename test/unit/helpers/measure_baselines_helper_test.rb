require 'test_helper'

class MeasureBaselinesHelperTest < ActionView::TestCase
  setup do
    dump_database
    load_measure_baselines
  end

  test "get_target_range_css_class should treat non-numeric as no data" do
    assert_equal "no-data-value", get_target_range_css_class(nil, nil, nil)
    assert_equal "no-data-value", get_target_range_css_class(nil, "test", nil)
    assert_equal "no-data-value", get_target_range_css_class(nil, "30%", nil)  # Needs it to be a number
  end

  test "get_target_range_css_class should handle poor ranges" do
    assert_equal "poor-measure-value", get_target_range_css_class(nil, 49, false)
    assert_equal "poor-measure-value", get_target_range_css_class(nil, "49", false)
    assert_equal "poor-measure-value", get_target_range_css_class(nil, 49.9, false)
    assert_equal "poor-measure-value", get_target_range_css_class(nil, 0, false)
  end

  test "get_target_range_css_class should handle medium ranges" do
    assert_equal "medium-measure-value", get_target_range_css_class(nil, 69, false)
    assert_equal "medium-measure-value", get_target_range_css_class(nil, "69", false)
    assert_equal "medium-measure-value", get_target_range_css_class(nil, 69.9, false)
    assert_equal "medium-measure-value", get_target_range_css_class(nil, 50, false)
  end

  test "get_target_range_css_class should handle good ranges" do
    assert_equal "good-measure-value", get_target_range_css_class(nil, 100, false)
    assert_equal "good-measure-value", get_target_range_css_class(nil, "100", false)
    assert_equal "good-measure-value", get_target_range_css_class(nil, 70.1, false)
    assert_equal "good-measure-value", get_target_range_css_class(nil, 70, false)
  end

  test "get_target_range_css_class should allow ranges to be changed" do
    original_config = APP_CONFIG["measure_baseline_ranges"]
    APP_CONFIG["measure_baseline_ranges"] = {"good" => 30.0, "medium" => 20.0, "poor" => 0.0}
    assert_equal "good-measure-value", get_target_range_css_class(nil, 30.1, false)
    assert_equal "medium-measure-value", get_target_range_css_class(nil, 20.1, false)
    assert_equal "poor-measure-value", get_target_range_css_class(nil, 0, false)
    APP_CONFIG["measure_baseline_ranges"] = original_config
  end

  test "get_target_range_css_class uses the order of baseline sources for its range" do
    baselines = MeasureBaseline.where(measure_id: "0013")
    assert_equal "good-measure-value", get_target_range_css_class(baselines, 10.1, false)
    assert_equal "medium-measure-value", get_target_range_css_class(baselines, 5.1, false)
    assert_equal "poor-measure-value", get_target_range_css_class(baselines, 0, false)
  end

  test "get_target_range_css_class compares for 'lower is better' measures" do
    original_config = APP_CONFIG["measure_baseline_ranges"]
    APP_CONFIG["measure_baseline_ranges"] = {"good" => 10.0, "medium" => 20.0, "poor" => 100.0}
    assert_equal "good-measure-value", get_target_range_css_class(nil, 9.9, true)
    assert_equal "medium-measure-value", get_target_range_css_class(nil, 19.9, true)
    assert_equal "poor-measure-value", get_target_range_css_class(nil, 20.1, true)
    APP_CONFIG["measure_baseline_ranges"] = original_config
  end

  test "replaces URLs with HTML link" do
    assert_nil auto_link(nil)
    assert_equal "See <a href=\"http://www.google.com\">http://www.google.com</a>", auto_link("See http://www.google.com")
  end

  test "adds footnotes to collection" do
    footnotes = []
    assert_false add_footnote(nil, footnotes)
    assert add_footnote("Test", footnotes)
    assert_equal 1, footnotes.length
    assert_false add_footnote("", footnotes)
  end
end

