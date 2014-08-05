Spree::Store.class_eval do
  set_table_name 'public.spree_stores'

  after_create :setup_schema
  after_create :create_template_and_assets_paths, if: ->(_r) { Rails.env.development? }

  def templates_base_path
    File.join(Rails.root, 'app', 'stores', code)
  end

  def create_template_and_assets_paths
    views = File.join(templates_base_path, 'views')
    FileUtils.mkdir_p(views) unless File.exist?(views)

    images = File.join(Rails.root, 'app', 'assets', 'images', 'stores', code)
    FileUtils.mkdir_p(images) unless File.exist?(images)

    css_files = File.join(Rails.root, 'app', 'assets', 'stylesheets', 'stores')
    FileUtils.mkdir_p(css_files) unless File.exist?(css_files)
    FileUtils.touch(File.join(css_files, "#{code}.css"))

    js_files = File.join(Rails.root, 'app', 'assets', 'javascripts', 'stores')
    FileUtils.mkdir_p(js_files) unless File.exist?(js_files)
    FileUtils.touch(File.join(js_files, "#{code}.js"))
  end

  private

  def setup_schema
    return unless Multitenant::SchemaUtils.schema_exists?(code)
    Multitenant::SchemaUtils.create_schema(code)
    Multitenant::SchemaUtils.load_schema_into_schema(code)
  end
end
