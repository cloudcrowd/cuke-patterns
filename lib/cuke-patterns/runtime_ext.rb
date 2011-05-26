module CukePatterns

  # For extending the Cucumber::Runtime class
  module RuntimeExt

    def self.included(runtime_class)
      runtime_class.class_eval do
        alias_method :load_step_definitions_without_cuke_patterns, :load_step_definitions
        alias_method :load_step_definitions, :load_step_definitions_with_cuke_patterns

        alias_method :run_without_cuke_patterns!, :run!
        alias_method :run!, :run_with_cuke_patterns!
      end

      super
    end

    def load_step_definitions_with_cuke_patterns
      result = load_step_definitions_without_cuke_patterns
      @support_code.apply_cuke_patterns_to_delayed_step_definition_registrations!
      return result
    end

    def run_with_cuke_patterns!
      run_without_cuke_patterns!
    end

    # For extending the Cucumber::Runtime::SupportCode class
    module SupportCodeExt

      def apply_cuke_patterns_to_delayed_step_definition_registrations!
        @programming_languages.each do |programming_language|
          programming_language.apply_cuke_patterns_to_delayed_step_definition_registrations!
        end
      end

    end
  end

end

if Cucumber.const_defined?(:Runtime)
  Cucumber::Runtime.class_eval { include CukePatterns::RuntimeExt }
  if Cucumber::Runtime.const_defined?(:SupportCode)
    Cucumber::Runtime::SupportCode.class_eval { include CukePatterns::RuntimeExt::SupportCodeExt }
  end
end
