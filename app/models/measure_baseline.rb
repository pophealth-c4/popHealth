class MeasureBaseline
  include Mongoid::Document
  
  field :measure_id, type: String
  field :sub_id, type: String
  field :start_date, type: Integer
  field :end_date, type: Integer
  field :calculation_date, type: Integer
  field :measure_baseline_source_id, type: BSON::ObjectId
  field :result, type: Hash
  field :target_range, type: Hash

  belongs_to :measure_baseline_source

  def self.search measure_id, sub_id, start_date, end_date, source_id
    results = {}
    if start_date.nil? or end_date.nil?
      results = MeasureBaseline.where(measure_id: measure_id, sub_id: sub_id).desc(:end_date).desc(:calculation_date)
    else
      results = MeasureBaseline.where(measure_id: measure_id, sub_id: sub_id, end_date: end_date, start_date: start_date).desc(:calculation_date)
      # If an exact match isn't found, we will return a baseline where the specified period is contained within
      # the baseline period.  Future work may relax this, but right now we are requiring it to be fully contained
      # and not overlapping.
      if results.first.nil?
        results = MeasureBaseline.where(measure_id: measure_id, sub_id: sub_id,
          :start_date => {'$lte' => [start_date, end_date].max},
          :end_date => {'$gte' => end_date} ).desc(:calculation_date)
      end
    end

    results = results.where(measure_baseline_source_id: source_id) unless source_id.nil?
    results.first
  end

  def target_range
    target_range_attr = read_attribute(:target_range)
    if target_range_attr.nil? or target_range_attr.length == 0
      return APP_CONFIG['measure_baseline_ranges']
    else
      return target_range_attr
    end
  end
end