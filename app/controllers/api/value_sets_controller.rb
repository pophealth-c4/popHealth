module Api
  class ValueSetsController < ApplicationController
    respond_to :json
    skip_authorization_check
    
    api :GET, '/value_sets'
    def index
      render json: [{:id => 1, :name => "Test 1"}, {:id => 2, :name => "Test 2"}]
    end
  end
end