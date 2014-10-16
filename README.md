SpreeMultiTenant
================

[![Build Status](https://travis-ci.org/masterkain/spree_multi_tenant.png?branch=2-3-stable)](https://travis-ci.org/masterkain/spree_multi_tenant)

Adds multi-tenant support to Spree. Allows completely separate Spree sites with separate admins to be run from the same installation.


Install
=======

Gemfile:

```ruby
gem 'spree', github: 'spree/spree', branch: '2-4-stable'
gem 'spree_auth_devise', github: 'spree/spree_auth_devise', branch: '2-4-stable'
gem 'spree_multi_tenant', github: 'KosenkoDmitriy/spree_multi_tenant', branch: '2-4-stable'
```

```shell
bundle install
```

Generate and run migrations:

```shell
bundle exec rake spree_multi_tenant:install:migrations
bundle exec rake db:migrate
````


Creating the first tenant
=========================

Create the first tenant and assign all existing items to it:

```shell
bundle exec rake spree_multi_tenant:create_tenant_and_assign name=mydomain code=mydomain.ru url=mydomain.ru mail_from_address=mydomain@mydomain.ru default_currency=RUB

```

Put tenant specific template, CSS and JS files here:

```
app/tenants/mydomain/views/
app/assets/stylesheets/tenants/mydomain.css
app/assets/javascripts/tenants/mydomain.js
```


Creating more tenants
=====================

Create another tenant (without anything assigned):

```shell
bundle exec rake spree_multi_tenant:create_tenant_and_assign name=anotherdomain code=anotherdomain.ru url=anotherdomain.ru mail_from_address=anotherdomain@anotherdomain.ru default_currency=RUB

```

Or from the console:

```ruby
Spree::Store.create!({:url => "anotherdomain.ru", code:"anotherdomain.ru", name:"anotherdomain", mail_from_address:"anotherdomain@anotherdomain.ru", default_currency:"RUB"})
```


With other Spree plugins
========================

Any other models that are to be tenant specific will need to have the tenant\_id field and multitenant scope added.

Database migration (e.g. db/migrate/XXXXXXXXXXXXXX_add_tenant_to_some_models.rb):

```ruby
class AddTenantToSomeModels < ActiveRecord::Migration
  def change
    tables = [
      "spree_pages",
      "spree_paypal_accounts",
      "spree_product_groups",
    ]
    tables.each do |table|
      add_column table, :store_id, :integer
      add_index table, :store_id
    end
  end
end
```

Add scope to the models (e.g. app/models/multitenant_decorator.rb):

```ruby
models = [
  Spree::Page,
  Spree::PaypalAccount,
  Spree::ProductGroup,
]
models.each do |model|
  model.class_eval do
    belongs_to :store
    belongs_to_multitenant
  end
end
```


In a Raketask
=============

Something like this:

```ruby
SpreeMultiTenant.with_tenant(Spree::Store.find_by_code('mydomain')) do
  # Do stuff for tenant. e.g.
  puts Spree::Product.first.name
end
```


Testing
=======

```shell
bundle
bundle exec rake test_app
bundle exec rspec spec
```


TODO
====

- Don't require spree_auth_devise as a depandancy.
- Allow same user email address to be used on multiple sites.
- Allow tenant specific Deface overrides.
- Allow same parmalinks to be used on multiple sites.
- Example CSS and JS files.
- Should CSS and JS files be grouped under app/tenants instead of app/assets? (e.g. app/tenants/mydomain/assets/stylesheets/store.css)
- Initialise preferences.


Original work copyright (c) 2014 Stefan Senk, released under the New BSD License
