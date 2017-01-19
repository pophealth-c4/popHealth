class ImportArchiveJob
  attr_accessor :file, :current_user, :practice
  
  def initialize(options)
    @file = options['file'].path
    @current_user = options['user']
    @practice = options['practice']
  end

  def before
    Log.create(:username => @current_user.username, :event => 'record import')
  end

  def perform
    begin
      missing_patients = BulkRecordImporter.import_archive(File.new(@file), nil, @practice)
    rescue => e
      Log.create(:username => @current_user.username, :event => "File-import: #{@file} error:"+e)
      puts Date.new+':'+e.backtrace
      raise
    end
    missing_patients.each do |id|
      Log.create(:username => @current_user.username, :event => "patient was present in patient manifest but not found after import", :medical_record_number => id)
    end
  end

  def after
    File.delete(@file)
    HealthDataStandards::CQM::QueryCache.delete_all
    PatientCache.delete_all    
  end
end
