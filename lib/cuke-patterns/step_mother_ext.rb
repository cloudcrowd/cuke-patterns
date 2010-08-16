module CukePatterns

  # For extending the Cucumber::StepMother class
  module StepMotherExt

    def self.included(step_mother_class)
      step_mother_class.class_eval do
        alias_method :load_code_files_without_cuke_patterns, :load_code_files
        alias_method :load_code_files, :load_code_files_with_cuke_patterns
      end

      super
    end

    def load_code_files_with_cuke_patterns(step_def_files)
      result = load_code_files_without_cuke_patterns(step_def_files)
      @programming_languages.each do |programming_language|
        programming_language.apply_cuke_patterns_to_delayed_step_definition_registrations!
      end
      return result
    end

  end

end

Cucumber::StepMother.class_eval do
  include CukePatterns::StepMotherExt
end
