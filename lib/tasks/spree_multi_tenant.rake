# Multitenant migrations.
namespace :stores do
  namespace :db do
    desc "runs db:migrate on each tenant's private schema"
    task migrate: :environment do
      verbose = ENV['VERBOSE'] ? ENV['VERBOSE'] == 'true' : true
      ActiveRecord::Migration.verbose = verbose
      Spree::Store.all.each do |tenant|
        puts "Migrating tenant #{tenant.id} (#{tenant.url})"
        version = ENV['VERSION'] ? ENV['VERSION'].to_i : nil
        Multitenant::SchemaUtils.migrate_schema(tenant.code, version)
      end
    end
  end
end
