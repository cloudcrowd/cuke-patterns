module CukePatterns
  module RbDslExt

    def apply_rb_cuke_pattern(name, string, world)
      @rb_language.apply_rb_cuke_pattern(name, string, world)
    end

    def register_rb_cuke_pattern(*args, &proc)
      @rb_language.register_rb_cuke_pattern(*args, &proc)
    end

    def register_rb_cuke_pattern_generator(&proc)
      @rb_language.register_rb_cuke_pattern_generator(&proc)
    end

  end
end

Cucumber::RbSupport::RbDsl.module_eval do
  extend CukePatterns::RbDslExt

  def Pattern(*args, &proc)
    Cucumber::RbSupport::RbDsl.register_rb_cuke_pattern(*args, &proc)
  end

  def PatternGenerator(&proc)
    Cucumber::RbSupport::RbDsl.register_rb_cuke_pattern_generator(&proc)
  end
end
