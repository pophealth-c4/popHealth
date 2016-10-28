module Api
  class ValueSetsController < ApplicationController
    respond_to :json
    #before_filter :authenticate_user!
    skip_authorization_check

    api :GET, '/value_sets/:oid?search=:search'
    param :oid, String, :desc => "Value set OID", :required => true
    param :search, String, :desc => "Value set term search string", :required => false
    def show
      value_set = HealthDataStandards::SVS::ValueSet.where({oid: params[:oid]}).first
      render json: value_set.concepts.all({display_name: /.*#{params[:search]}.*/ })
    end
  end
end