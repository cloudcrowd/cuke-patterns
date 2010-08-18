module CukePatterns

  module RbWorldExt

    def Pattern(name, string)
      Cucumber::RbSupport::RbDsl.apply_rb_cuke_pattern(name, string)
    end

  end

end

Cucumber::RbSupport::RbWorld.module_eval do
  include CukePatterns::RbWorldExt
end
