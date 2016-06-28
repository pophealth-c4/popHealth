module MeasureBaselinesHelper
  def get_target_range_css_class(baselines, value, lower_is_better)
    if is_number?(value)
      value = value.to_f

      # Get the first baseline that is flagged as the comparison baseline
      # This assumes (given the way we return baselines) that the list is
      # sorted in display order
      baseline = baselines.detect{ |bl| !bl.nil? && bl.measure_baseline_source.use_as_comparison } unless baselines.nil?

      measure_baseline_ranges = baseline.target_range unless baseline.nil?
      measure_baseline_ranges ||= APP_CONFIG['measure_baseline_ranges']

      if lower_is_better
        if value <= measure_baseline_ranges["good"]
          return "good-measure-value"
        elsif value <= measure_baseline_ranges["medium"]
          return "medium-measure-value"
        else
          return "poor-measure-value"
        end
      else
        if value >= measure_baseline_ranges["good"]
          return "good-measure-value"
        elsif value >= measure_baseline_ranges["medium"]
          return "medium-measure-value"
        else
          return "poor-measure-value"
        end
      end
    end

    return "no-data-value"
  end

  def auto_link str
    return nil if str.nil?
    URI.extract(str, ['http', 'https']).each do |uri|
      str = str.gsub( uri, "<a href=\"#{uri}\">#{uri}</a>" )
    end
    str
  end

  def add_footnote(reference, footnotes)
    unless reference.nil? or reference.blank?
      footnotes << auto_link(reference)
      return true
    end
    false
  end

  def is_number? string
    true if Float(string) rescue false
  end
end