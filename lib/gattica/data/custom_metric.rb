require 'rubygems'
require 'json'

module Gattica
  module Data
    class CustomMetric
      include Convertible

      attr_reader :id, :name, :index, :scope, :active, :type, :min_value,
                  :max_value, :updated, :created, :account_id, :web_property_id

      def initialize(json)
        @id = json['id']
        @account_id = json['accountId']
        @web_property_id = json['webPropertyId']
        @name = json['name']
        @index = json['index']
        @scope = json['scope']
        @active = json['active']
        @type = json['type']
        @min_value = json['min_value']
        @max_value = json['max_value']
        @updated = DateTime.parse(json['updated']) if json['updated']
        @created = DateTime.parse(json['created']) if json['created']
      end
    end
  end
end