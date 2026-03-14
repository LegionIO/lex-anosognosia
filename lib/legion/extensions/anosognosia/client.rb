# frozen_string_literal: true

require 'legion/extensions/anosognosia/helpers/constants'
require 'legion/extensions/anosognosia/helpers/cognitive_deficit'
require 'legion/extensions/anosognosia/helpers/anosognosia_engine'
require 'legion/extensions/anosognosia/runners/anosognosia'

module Legion
  module Extensions
    module Anosognosia
      class Client
        include Runners::Anosognosia

        def initialize(**)
          @engine = Helpers::AnosognosiaEngine.new
        end

        private

        attr_reader :engine
      end
    end
  end
end
