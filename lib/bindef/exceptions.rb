# frozen_string_literal: true

class Bindef
  # The base exception for all {Bindef} errors.
  class BindefError < RuntimeError
  end

  # Raised during an error in evaluation.
  class EvaluationError < BindefError
  end

  # Raised during an error in pragma evaluation.
  class PragmaError < EvaluationError
  end

  # Raised during an error in command evaluation.
  class CommandError < EvaluationError
  end
end
