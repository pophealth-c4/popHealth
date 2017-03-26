class ProvidersController < ApplicationController
  include LogsHelper

  before_filter :authenticate_user!
  before_filter :set_provider
  before_filter :validate_authorization!

  # GET /practice
  # GET /practice.json
  def measure_baseline
    @effective_start_date = params["start_date"] || current_user.effective_start_date
    @effective_date = params["end_date"] || current_user.effective_date
    @baseline_sources = MeasureBaselineSource.all.entries
    @provider = Provider.find(params[:provider_id])
    measure_ids = current_user.preferences['selected_measure_ids']

    @results = Hash.new
    unless measure_ids.empty?
      selected_measures = measure_ids.map{ |id| HealthDataStandards::CQM::Measure.where(:id => id, :continuous_variable => false) }
      selected_measures.each do |measure|
        measure.sort_by!{|s| s.sub_id}.each do |sub|
          entry_key = sub.measure_id + (sub.sub_id.nil? ? '' : '_' + sub.sub_id)
          @results[entry_key] = {}
          query = {:measure_id => sub.hqmf_id, :sub_id => sub.sub_id, :effective_date => @effective_date, 'filters.providers' => [params[:provider_id].to_s]}
          cache = QME::QualityReport.where(query).first
          unless cache.nil? or cache.result.nil?
            performance_denominator = cache.result['DENOM'] - cache.result['DENEX']
            @results[entry_key][:result] =  percentage(cache.result['NUMER'].to_f, performance_denominator.to_f)
          else
            @results[entry_key][:result] = nil
          end
          @results[entry_key][:measure] = sub
          @results[entry_key][:baseline] = Hash.new
          @baseline_sources.each do |source|
            @results[entry_key][:baseline][source.id] = MeasureBaseline.search(sub.measure_id, sub.sub_id, @effective_start_date, @effective_date, source.id)
          end
        end
      end
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @practice }
    end
  end

  private
    def set_provider
      @provider = Provider.find(params[:id] || params[:provider_id])
      validate_authorization!
    end

    def validate_authorization!
      authorize! :read, @provider
    end

    def percentage(numer, denom)  
      if denom == 0
        0
      else
        (numer/denom * 100).round(1)
      end
    end
end
