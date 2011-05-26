module CukePatterns

  # For extending the Cucumber::RbSupport::RbLanguage class
  module RbLanguageExt

    def self.included(rb_language_class)
      rb_language_class.class_eval do
        alias_method :register_rb_step_definition_without_cuke_patterns, :register_rb_step_definition
        alias_method :register_rb_step_definition, :register_rb_step_definition_with_cuke_patterns

        alias_method :after_configuration_without_cuke_patterns, :after_configuration
        alias_method :after_configuration, :after_configuration_with_cuke_patterns
      end

      super
    end

    def after_configuration_with_cuke_patterns(*args)
      apply_cuke_patterns_to_delayed_step_definition_registrations!
      after_configuration_without_cuke_patterns(*args)
    end

    def apply_cuke_patterns_to_delayed_step_definition_registrations!
      count = 0
      cuke_pattern_delayed_step_definition_registrations.each do |matcher, proc|
        regexp, converted_proc = convert_cuke_patterns_and_proc(matcher, proc)
        register_rb_step_definition(regexp, converted_proc)
        count += 1
      end

      # Clean up our mess!
      remove_instance_variable('@cuke_pattern_delayed_step_definition_registrations')
    end

    def cuke_patterns
      @cuke_patterns ||= {}
    end

    # Hook this method to automatically generate regexp matches for words in step
    # definition strings that *don't* match to registered patterns.
    def default_cuke_pattern(key)
      default_cuke_pattern_generators.each do |generator|
        regexp, proc = generator[key]
        return regexp, proc if regexp
      end
      return nil
    end

    def default_cuke_pattern_generators
      @default_cuke_pattern_generators ||= []
    end

    def apply_rb_cuke_pattern(name, string, world)
      name = ":#{name}" if name.is_a?(Symbol)
      regexp, proc = lookup_cuke_pattern(name)
      match = regexp.match(string)
      raise "Pattern #{regexp.to_s} does not match #{string.inspect}" unless match
      return world.instance_exec(*match.captures, &proc) if proc
      return match.to_s
    end

    def lookup_cuke_pattern(name)
      keys, regexp, proc = [], nil, nil
      cuke_patterns.each do |key, value|
        if key === name
          keys << key
          regexp, proc = value
        end
      end
      return default_cuke_pattern(name) if keys.empty?
      return regexp, proc if keys.length == 1
      raise "Ambiguous Pattern for #{name.inspect}: #{keys.inspect}"
    end

    def register_rb_cuke_pattern(*args, &conversion_proc)
      if args.length == 1
        if args.first.is_a?(Hash)
          args.first.each do |key, value|
            register_rb_cuke_pattern(key, value, &conversion_proc)
          end
          return
        else
          # We wrap the key form of the regexp in begin/end
          # so that we match only whole tokens when doing lookup
          name = Regexp.new("^(?:#{args.first})$")
          regexp = args.first
        end
      elsif args.length == 2
        name, regexp = args
        name = ":#{name}" if name.is_a?(Symbol) # so :user becomes ':user'
      end

      if conversion_proc
        # Count the capturing '(' characters to get the pattern arity
        pattern_capture_count = capture_count_for(regexp)

        if pattern_capture_count != conversion_proc.arity
          raise "There are #{pattern_capture_count} of capture(s) in Pattern #{name} but block arity is #{conversion_proc.arity}"
        end
      end

      return cuke_patterns[name] = [regexp, conversion_proc]
    end

    def register_rb_cuke_pattern_generator(&proc)
      default_cuke_pattern_generators << proc
    end

    def register_rb_step_definition_with_cuke_patterns(matcher, proc)
      return register_rb_step_definition_without_cuke_patterns(matcher, proc) unless matcher.is_a?(String)
      cuke_pattern_delayed_step_definition_registrations << [matcher, proc]
      return :registration_delayed_by_cuke_patterns
    end

    private

    def capture_count_for(regexp)
      regexp.to_s.gsub(/\\\\|\\\(|\(\?/,'').scan(/\(/).length
    end

    # Given a Step Definition's string aka 'matcher' and its Proc, generate a Regexp and
    # new Proc by replacing all the Patterns in the String matcher with their Regexps etc.
    def convert_cuke_patterns_and_proc(matcher, proc)

      matcher_regexp = "^"

      capture_counter = 0

      # Split the string by non-alphanumeric, underscore or leading-colon characters
      matcher.scan(/(:?\w+)|([^:\w]+|:)/) do |candidate, non_candidate|

        regexp, conversion_proc = lookup_cuke_pattern(candidate) if candidate

        if non_candidate or not regexp
          matcher_regexp << Regexp.escape(candidate || non_candidate)
          next
        end

        pattern_capture_count = capture_count_for(regexp)

        proc = convert_cuke_pattern_proc_arguments(
          proc, conversion_proc,
          capture_counter, pattern_capture_count) if conversion_proc

        capture_counter += pattern_capture_count

        matcher_regexp << regexp.to_s

      end

      matcher_regexp << "$"

      return [Regexp.new(matcher_regexp), proc]
    end

    # Returns a new Proc/block made by applying the conversion_block to a number of
    # the arguments yielded to the original_block (arg_count) at the offset.
    def convert_cuke_pattern_proc_arguments(original_proc, conversion_proc, offset, arg_count)

      # The number of arguments of the new Proc should be the number of arguments of the
      # old Proc with the change that an argument in the old Proc will potentialy now be
      # converted into a multiple-capture.
      arity = original_proc.arity + arg_count - 1
      arg_list = (1..arity).map{|n| "arg#{n}"}.join(",")

      file, line = original_proc.file_colon_line.split(/:/,2)
      line = line.to_i

      new_proc = instance_eval(<<-ruby, file, line)
        Proc.new do |#{arg_list}|

          args = [#{arg_list}]
          arg_range = offset..(offset + arg_count - 1)
          converted_args = instance_exec(*args[arg_range], &conversion_proc)
          args.slice!(arg_range)
          args.insert(offset, converted_args)
          instance_exec(*args, &original_proc)
        end
      ruby

      class << new_proc; self end.module_eval do
        define_method(:file_colon_line){ original_proc.file_colon_line }
      end

      return new_proc
    end

    def cuke_pattern_delayed_step_definition_registrations
      @cuke_pattern_delayed_step_definition_registrations ||= []
    end

  end

end

Cucumber::RbSupport::RbLanguage.class_eval do
  include CukePatterns::RbLanguageExt
end

