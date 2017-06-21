require 'yaml'
require 'digest'

require 'codebreaker/version'
require 'codebreaker/game'

module Codebreaker
  MIN_DIGIT = 1
  MAX_DIGIT = 6

  NUM_OF_TRIES = 5
  NUM_OF_DIGITS = 4

  WIN_CODE_REGEXP = Regexp.new "^\\+{#{NUM_OF_DIGITS}}$"
  CODE_REGEXP = Regexp.new "^[#{MIN_DIGIT}-#{MAX_DIGIT}]+$"

  private_constant :MIN_DIGIT
  private_constant :MAX_DIGIT

  private_constant :NUM_OF_TRIES
  private_constant :NUM_OF_DIGITS
end
