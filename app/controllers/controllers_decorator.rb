
class Spree::Preferences::StoreInstance
  # Initialize the preference without writing to the database
  def set_without_persist(key, value)
    @cache.write(key, value)
  end
end

module SpreeMultiTenant
  def self.init_preferences
    Spree::Preference.all.each do |preference|
      Spree::Preferences::Store.instance.set_without_persist(preference.key, preference.value)
    end
  end
end

SpreeMultiTenant.tenanted_controllers.each do |controller|
  controller.class_eval do

    prepend_around_filter :store_scope

    def current_tenant
      Multitenant.current_tenant
    end

    private

    def store_scope
      store = Spree::Store.by_url(request.env['SERVER_NAME']).first
      raise 'DomainUnknown' unless store

      # Add Spree::Store views path
      path = "app/stores/#{store.code}/views"
      prepend_view_path(path)

      # Execute ActiveRecord queries within the scope of the store
      SpreeMultiTenant.with_tenant(store) do
        yield
      end
    end
  end
end
