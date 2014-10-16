def do_create_tenant name, code, url, mail_from_address
  if url.blank? or code.blank? or name.blank? or mail_from_address.blank?
    puts "Error: url, name, code and mail_from_address must be specified"
    puts "(e.g. rake spree_multi_tenant:create_tenant name=mydomain.ru url=mydomain.ru code=mydomain mail_from_address=mydomain@mydomain.ru)"
    exit
  end

  tenant = Spree::Store.create!({:url => url.dup, code:code.dup, name:name.dup, mail_from_address:mail_from_address.dup, default_currency:"RUB"})
  #{:url => url.dup, :code => code.dup})
  tenant.create_template_and_assets_paths
  tenant
end


namespace :spree_multi_tenant do

  desc "Create a new tenant and assign all exisiting items to the tenant."
  task :create_tenant_and_assign => :environment do
    tenant = do_create_tenant ENV["name"], ENV["url"], ENV["code"],ENV["mail_from_address"]

    # Assign all existing items to the new tenant
    SpreeMultiTenant.tenanted_models.each do |model|
      model.all.each do |item|
        item.update_attribute(:store_id, tenant.id)
      end
    end
  end

  desc "Create a new tenant"
  task :create_tenant => :environment do
    tenant = do_create_tenant  ENV["name"], ENV["code"], ENV["url"], ENV["mail_from_address"]
  end

end
