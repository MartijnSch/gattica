require 'rubygems'
require 'json'

module Gattica
  module Data
    class Upload
    	include Convertible

      attr_reader :id, :account_id, :custom_data_source_id, :status

      def initialize(json)
        @id = json['id']
        @account_id = json['accountId']
        @custom_data_source_id = json['customDataSourceId']
        @status = json['status']
      end
    end
  end
end
