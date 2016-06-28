require 'json'

module Measures
  class BaselineLoader
    def self.import_json(json_path, clear_existing)
      clear_existing ||= false

      if (clear_existing)
        MeasureBaselineSource.delete_all
        MeasureBaseline.delete_all
      end

      collection = JSON.parse(File.read(json_path))
      collection.each do |record|
        source = MeasureBaselineSource.where(name: record["source"]["name"]).first
        source = MeasureBaselineSource.create(record["source"]) if source.nil?
        unless record["baselines"].nil?
          record["baselines"].each do |baseline|
            new_baseline = MeasureBaseline.new(baseline)
            new_baseline.measure_baseline_source = source
            new_baseline.save
          end
        end
      end
    end
  end
end