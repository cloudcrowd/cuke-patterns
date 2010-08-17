module CukePatterns

  # For extending the Cucumber::RbSupport::RbLanguage class
  module RbLanguageExt

    def self.included(rb_language_class)
      rb_language_class.class_eval do
        alias_method :register_rb_step_definition_without_cuke_patterns, :register_rb_step_definition
        alias_method :register_rb_step_definition, :register_rb_step_definition_with_cuke_patterns
      end

      super
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
      @cuke_patterns ||= Hash.new {|hash, key| default_cuke_pattern(key)}
    end

    # Hook this method to automatically generate regexp matches for words in step
    # definition strings that *don't* match to registered patterns.
    def default_cuke_pattern(key)
      default_cuke_pattern_generators.each do |generator|
        regexp, proc = generator[key]
        return [regexp, proc] if regexp
      end
      return nil
    end

    def default_cuke_pattern_generators
      @default_cuke_pattern_generators ||= []
    end

    def apply_rb_cuke_pattern(name, string)
      name = ":#{name}" if name.is_a?(String)
      regexp, proc = cuke_patterns[name]
      match = regexp.match(string)
      raise "Pattern #{regexp.to_s} does not match #{string.inspect}" unless match
      return instance_exec(*match.captures, &proc) if proc
      return match.to_s
    end

    def register_rb_cuke_pattern(name, regexp, &conversion_proc)
      name = ":#{name}" if name.is_a?(Symbol) # so :user becomes ':user'

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

    def convert_cuke_patterns_and_proc(matcher, proc)

      matcher_regexp = "^"

      pattern_counter = 0
      capture_counter = 0

      # Split the string by non-alphanumeric, underscore or leading-colon characters
      matcher.scan(/(:?\w+)|([^:\w]+|:)/) do |candidate, non_candidate|

        regexp, conversion_proc = cuke_patterns[candidate] if candidate

        if non_candidate or not regexp
          matcher_regexp << Regexp.escape(candidate || non_candidate)
          next
        end

        pattern_capture_count = capture_count_for(regexp)

        proc = convert_cuke_pattern_proc_arguments(
          proc, conversion_proc,
          pattern_counter, pattern_capture_count) if conversion_proc

        pattern_counter += 1 unless pattern_capture_count == 0
        capture_counter += pattern_capture_count

        matcher_regexp << "(?:#{regexp})"

      end

      matcher_regexp << "$"

      return [Regexp.new(matcher_regexp), proc]
    end

    # Returns a new Proc/block made by applying the conversion_block to a number of
    # the arguments yielded to the original_block (arg_count) at the offset.
    def convert_cuke_pattern_proc_arguments(original_proc, conversion_proc, offset, arg_count)

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

