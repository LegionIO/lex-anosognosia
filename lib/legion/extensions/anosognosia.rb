# frozen_string_literal: true

require 'legion/extensions/anosognosia/version'
require 'legion/extensions/anosognosia/helpers/constants'
require 'legion/extensions/anosognosia/helpers/cognitive_deficit'
require 'legion/extensions/anosognosia/helpers/anosognosia_engine'
require 'legion/extensions/anosognosia/runners/anosognosia'

module Legion
  module Extensions
    module Anosognosia
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
