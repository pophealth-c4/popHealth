module C4Helper
  class Cat1Exporter
    attr_accessor :measures
    attr_accessor :start_time
    attr_accessor :end_time
    # note bad redundancy: have to declare version on init
    # (don't know if call on export matters at all -- should be one or the other)
    CAT1EXPORTER = HealthDataStandards::Export::Cat1.new('r3_1')

    def initialize
      # define @measures, @start_time @end_time from query_cache  use pushnew? with measures
      measids=[]
      QME::QualityReport.all.each { |qr|
        @start_time=qr['start_time']
        @end_time=qr['effective_time']
        measids.push(qr['measure_id']) if !measids.include?(qr['measure_id'])
      }
      @measures = QME::QualityMeasure.in(:_id => measids).to_a
    end

    def export(patient)
      # don't know about this one; try both ways
      cms_compatible = true # if patient.product_test && patient.product_test.product.c3_test
      # qrda version is hard coded right now!!!
      CAT1EXPORTER.export(patient, @measures, @start_time, @end_time, nil, 'r3_1', #patient.bundle.qrda_version,
                          cms_compatible)
    end

    def zip(file, patients)
      patients = apply_sort_to patients

      Zip::ZipOutputStream.open(file.path) do |z|
        patients.each_with_index do |patient, i|
          # safe_first_name = patient.first.delete("'")
          # safe_last_name = patient.last.delete("'")
          # next_entry_path = "#{i}_#{safe_first_name}_#{safe_last_name}"
          z.put_next_entry("#{next_entry_path(patient, i)}.qrda")
          z << export(patient)
        end
      end
    end

    def apply_sort_to(patients)
      if patients.is_a? Array
        patients.sort_by { |p| p.first + '_' + p.last }
      else
        patients.order_by(:first.asc, :last.asc)
      end
    end

    def next_entry_path(patient, index)
      safe_first_name = patient.first.delete("'")
      safe_last_name = patient.last.delete("'")
      "#{index}_#{safe_first_name}_#{safe_last_name}"
    end

  end

  # Problem: you have to be running on the same machine you loaded the original file from
  class Cat1ZipFilter
    attr_accessor :infile
    attr_accessor :user

    def initialize(user)
      @infile = user['current_file']
      @user = user
    end

    def pluck(outfilepath, patients)
      names=[]
      patients.each do |p|
        names.push(Regexp.new(p['first']+'_'+p['last']))
      end
      # Zip::OutputStream.open(outfilepath) do |zout|
      #   Zip::InputStream.open(@infile) do |zin|
      Zip::OutputStream.open(outfilepath, Zip::File::CREATE) do |zout|
        Zip::File.open(@infile) do |zin|
          zin.each do |entry|
            if !names.find{|e| e=~entry.name}.nil?
              entry.write_to_zip_output_stream(zout)
            end
          end
        end
        zout.close
      end
    end
  end
end
