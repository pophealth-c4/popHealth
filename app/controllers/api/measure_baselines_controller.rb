module Api
  class MeasureBaselinesController < ApplicationController
    resource_description do
      short 'Measure Baselines'
      formats ['json']
      description "This resource allows for the retrieval of baseline value for clinical quality measures in the popHealth application."
    end
    include LogsHelper
    before_filter :authenticate_user!
    before_filter :validate_authorization!

    api :GET, "/measure_baselines/:id", "Get a clinical quality measure baseline"
    param :id, String, :desc => 'The HQMF id for the CQM to calculate', :required => true
    param :sub_id, String, :desc => 'The sub id for the CQM to calculate. This is popHealth specific.', :required => false
    param :start_date, String, :desc => 'The start of the date range you are interested in for the measure period', :required => false
    param :end_date, String, :desc => 'The end of the date range you are interested in for the measure period', :required => false
    param :source_id, String, :desc => 'The source of the baseline information', :required => false
    def show
      results = MeasureBaseline.search params[:id], params[:sub_id], params[:start_date], params[:end_date], params[:source_id]
      render :json => results.nil? ? {} : results.to_json(:except => [:_id])
    end

    def validate_authorization!
      authorize! :read, MeasureBaseline
    end
  end
end