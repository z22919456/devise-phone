# frozen_string_literal: true

require 'rails/generators/base'

module DevisePhone
  module Generators
    class ViewsGenerator < Rails::Generators::Base
      desc 'Copies phone confirmation views to your application.'

      argument :scope, required: false, default: nil,
                       desc: 'The scope to copy views to'

      invoke Devise::Generators::SharedViewsGenerator

      hook_for :form_builder, aliases: '-b',
                              desc: 'Form builder to be used',
                              default: defined?(SimpleForm) ? 'simple_form_for' : 'form_for'

      hook_for :markerb,  desc: 'Generate markerb instead of erb mail views',
                          default: defined?(Markerb),
                          type: :boolean
    end
  end
end
