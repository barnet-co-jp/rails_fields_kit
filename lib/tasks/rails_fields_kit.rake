# frozen_string_literal: true

namespace :rails_fields_kit do
  desc "Report detectable Rails Fields Kit host app setup status"
  task :doctor do
    require "rails_fields_kit/setup_doctor"

    RailsFieldsKit::SetupDoctor.new.run
  end
end
