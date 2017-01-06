class C4Helper
  CAT1EXPORTER = HealthDataStandards::Export::Cat1.new
  def initialize
     # define @measures, @start_time @end_time from query_cache  use pushnew? with measures
  end
  def export_cat1_zip

  end
  def export(patient)
    cms_compatible = true if patient.product_test && patient.product_test.product.c3_test
    # qrda version is hard coded right now!!!
    CAT1EXPORTER.export(patient, measures, start_time, end_time, nil, patient.bundle.qrda_version, cms_compatible)
  end

  def zip
    # see patient_zipper.rb
  end

end
