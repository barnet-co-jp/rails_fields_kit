# frozen_string_literal: true

require "rails_fields_kit/version"
require "rails_fields_kit/configuration"
require "rails_fields_kit/searchable"
require "rails_fields_kit/engine"

module RailsFieldsKit
  class Error < StandardError; end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def reset_configuration!
      @configuration = Configuration.new
    end
  end
end
