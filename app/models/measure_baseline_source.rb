class MeasureBaselineSource
  include Mongoid::Document
  
  field :name, type: String
  field :display_order, type: Integer
  field :reference, type: String
  field :use_as_comparison, type: Boolean, default: false

  has_many :measure_baselines

  default_scope ->{ asc(:display_order) }
end