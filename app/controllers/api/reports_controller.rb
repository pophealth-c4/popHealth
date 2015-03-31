module Api

  class ReportsController < ApplicationController
    resource_description do
      short 'Reports'
      formats ['xml']
      description <<-RCDESC
        This resource is responsible for the generation of QRDA Category III reports from clincial
        quality measure calculations.
      RCDESC
    end
    before_filter :authenticate_user!
    skip_authorization_check

    api :GET, '/reports/qrda_cat3.xml', "Retrieve a QRDA Category III document"
    param :measure_ids, Array, :desc => 'The HQMF ID of the measures to include in the document', :required => false
    param :effective_date, String, :desc => 'Time in seconds since the epoch for the end date of the reporting period',
                                   :required => false
    param :provider_id, String, :desc => 'The Provider ID for CATIII generation'
    description <<-CDESC
      This action will generate a QRDA Category III document. If measure_ids and effective_date are not provided,
      the values from the user's dashboard will be used.
    CDESC
    def cat3
      measure_ids = params[:measure_ids] ||current_user.preferences["selected_measure_ids"]
      filter = measure_ids=="all" ? {}  : {:hqmf_id.in =>measure_ids}
      exporter =  HealthDataStandards::Export::Cat3.new
      effective_date = params["effective_date"] || current_user.effective_date || Time.gm(2012, 12, 31)
      end_date = Time.at(effective_date.to_i)
      provider = provider_filter = nil
      if params[:provider_id].present?
        provider = Provider.find(params[:provider_id])
        provider_filter = {}
        provider_filter['filters.providers'] = params[:provider_id] if params[:provider_id].present?
      end
      render xml: exporter.export(HealthDataStandards::CQM::Measure.top_level.where(filter),
                                   generate_header(provider),
                                   effective_date.to_i,
                                   end_date.years_ago(1),
                                   end_date, provider_filter), content_type: "attachment/xml"
    end

    api :GET, "/reports/patients" #/:id/:sub_id/:effective_date/:provider_id/:patient_type"
    param :id, String, :desc => "Measure ID", :required => true
    param :sub_id, String, :desc => "Measure sub ID", :required => false
    param :effective_date, String, :desc => 'Time in seconds since the epoch for the end date of the reporting period', :required => true
    param :provider_id, String, :desc => 'Provider ID for filtering quality report', :required => true
    param :patient_type, String, :desc => 'Outlier, Numerator, Denominator', :required => true
    description <<-CDESC
      This action will generate an Excel spreadsheet of relevant QRDA Category I Document based on the category of patients selected. 
    CDESC
    def patients
      type = params[:patient_type]        
      
      qr = QME::QualityReport.where(:effective_date => params[:effective_date].to_i, :measure_id => params[:id], :sub_id => params[:sub_id], "filters.providers" => params[:provider_id])
      records = (qr.count > 0) ? qr.first.patient_results : []
   
      book = Spreadsheet::Workbook.new
      sheet = book.create_worksheet
      format = Spreadsheet::Format.new :weight => :bold		  

      # report info
      
      
      # table headers
      sheet.row(0).push 'MRN', 'First Name', 'Last Name', 'Gender', 'Birthdate'
      sheet.row(0).default_format = format
      row = 1;
      
      records.each do |record|
        value = record.value
        if value["#{type}"] == 1
          sheet.row(row).push value[:medical_record_id], value[:first], value[:last], value[:gender], Time.at(value[:birthdate]).strftime("%D")
          row +=1
        end
      end

      today = Time.now.strftime("%D")  
      filename = "patients_" + "#{type}" + "_" + "#{today}" + ".xls"
      data = StringIO.new '';
      book.write data;
      send_data(data.string, {
        :disposition => 'attachment',
        :encoding => 'utf8',
        :stream => false,
        :type => 'application/excel',
        :filename => filename
      })
    end

    api :GET, "/reports/cat1/:id/:measure_ids"
    formats ['xml']
    param :id, String, :desc => "Patient ID", :required => true
    param :measure_ids, String, :desc => "Measure IDs", :required => true
    param :effective_date, String, :desc => 'Time in seconds since the epoch for the end date of the reporting period',
                                   :required => false
    description <<-CDESC
      This action will generate a QRDA Category I Document. Patient ID and measure IDs (comma separated) must be provided. If effective_date is not provided,
      the value from the user's dashboard will be used.
    CDESC
    def cat1
      exporter = HealthDataStandards::Export::Cat1.new
      patient = Record.find(params[:id])
      measure_ids = params["measure_ids"].split(',')
      measures = HealthDataStandards::CQM::Measure.where(:hqmf_id.in => measure_ids)
      end_date = params["effective_date"] || current_user.effective_date || Time.gm(2012, 12, 31)
      start_date = end_date.years_ago(1)
      render xml: exporter.export(patient, measures, start_date, end_date)
    end


    private

    def generate_header(provider)
      header = Qrda::Header.new(APP_CONFIG["cda_header"])

      header.identifier.root = UUID.generate
      header.authors.each {|a| a.time = Time.now}
      header.legal_authenticator.time = Time.now
      header.performers << provider

      header
    end
  end
end
