require 'json'
require 'measures/baseline_loader'
namespace :import do

  desc 'import patient records'
  task :patients, [:source_dir, :providers_predefined] do |t, args|
    if !args.source_dir || args.source_dir.size==0
      raise "please specify a value for source_dir"
    end
    HealthDataStandards::Import::BulkRecordImporter.import_directory(args.source_dir)
  end

  desc 'import measure baseline records from a JSON document'
  task :measure_baselines, [:json_path, :clear_existing] do |t, args|
    if !args.json_path || args.json_path.size == 0
      raise "please specify a value for json_path"
    end
    clear_existing = args.clear_existing || false
    Measures::BaselineLoader.import_json(args.json_path, clear_existing)
  end
end
