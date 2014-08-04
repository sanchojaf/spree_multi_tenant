
require 'active_record'

module SpreeMultiTenant
  module ActiveRecordExtensions
    def raise_error_if_no_tenant(association = :store)
      default_scope lambda {
        raise 'OperationWithNoTenant' unless Multitenant.current_tenant
      }
    end
  end
end
ActiveRecord::Base.extend SpreeMultiTenant::ActiveRecordExtensions

SpreeMultiTenant.tenanted_models.each do |model|
  model.class_eval do

    belongs_to :store, class_name: 'Spree::Store'
    belongs_to_multitenant(:store)
    # raise_error_if_no_tenant if Rails.env = 'production'   # TODO - would this be useful?
    validates :store_id, presence: true

    # always scope these models with the store, even if requested unscoped
    def self.unscoped
      r = relation
      r = r.where(:store_id => Multitenant.current_tenant.id) if Multitenant.current_tenant
      block_given? ? r.scoping { yield } : r
    end

  end
end

Spree::Core::Search::Base.class_eval do
  def get_base_scope
    base_scope = Spree::Product.active
    base_scope = base_scope.where(store_id: Multitenant.current_tenant.id) if Multitenant.current_tenant
    base_scope = base_scope.in_taxon(taxon) unless taxon.blank?
    base_scope = get_products_conditions_for(base_scope, keywords)
    base_scope = add_search_scopes(base_scope)
    base_scope
  end
end
