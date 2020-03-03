require "rails"

module SimpleFormNestedFields
 class Railtie < Rails::Railtie
   initializer "simple_form_dependent_fields.assets" do |app|
     app.config.assets.paths << SimpleFormNestedFields.asset_path
   end
 end
end
