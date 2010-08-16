module CukePatterns
  module RbDslExt

    def register_rb_cuke_pattern(name, regexp, &proc)
      @rb_language.register_rb_cuke_pattern(name, regexp, &proc)
    end

    def register_rb_cuke_pattern_generator(&proc)
      @rb_language.register_rb_cuke_pattern_generator(&proc)
    end

  end
end

Cucumber::RbSupport::RbDsl.module_eval do
  extend CukePatterns::RbDslExt

  def Pattern(name, regexp, &proc)
    Cucumber::RbSupport::RbDsl.register_rb_cuke_pattern(name, regexp, &proc)
  end

  def PatternGenerator(&proc)
    Cucumber::RbSupport::RbDsl.register_rb_cuke_pattern_generator(&proc)
  end
end
