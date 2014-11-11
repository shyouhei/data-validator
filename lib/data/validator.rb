#! /your/favourite/path/to/ruby
# -*- mode: ruby; coding: utf-8; indent-tabs-mode: nil; ruby-indent-level 2 -*-

# Copyright (c) 2014 Urabe, Shyouhei
#
# Permission is hereby granted, free of  charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction,  including without limitation the rights
# to use,  copy, modify,  merge, publish,  distribute, sublicense,  and/or sell
# copies  of the  Software,  and to  permit  persons to  whom  the Software  is
# furnished to do so, subject to the following conditions:
#
#         The above copyright notice and this permission notice shall be
#         included in all copies or substantial portions of the Software.
#
# THE SOFTWARE  IS PROVIDED "AS IS",  WITHOUT WARRANTY OF ANY  KIND, EXPRESS OR
# IMPLIED,  INCLUDING BUT  NOT LIMITED  TO THE  WARRANTIES OF  MERCHANTABILITY,
# FITNESS FOR A  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO  EVENT SHALL THE
# AUTHORS  OR COPYRIGHT  HOLDERS  BE LIABLE  FOR ANY  CLAIM,  DAMAGES OR  OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
Data::Validator = Class.new  # @!parse class Data::Validator; end
require_relative "validator/version"

class << Data::Validator
  alias bare_new new
  private :bare_new

  # Creates a new validator.
  # 
  # @overload new(hash)
  #   This is the basic validator that validates one hash
  #
  #   @param  [Hash]            hash     Describes validation rule.
  #   @return [Data::Validator]          Constructed validator.
  #
  # @overload new(array)
  #   What a `->with('Sequenced')` intends in perl version.  In perl a `(...)`
  #   can either be an array or a hash but in ruby they are different.
  #
  #   @param  [<Hash>]          array  Describes validation rule.
  #   @return [Data::Validator]        Constructed validator.
  #
  # @overload new(validator)
  #   For recursive call.
  #
  #   @param  [Data::Validator] validator A validator instance.
  #   @return [Data::Validator]           The argument.
  #
  # @overload new(object)
  #   Arbitrary objects can be specified, for simplicity.
  #
  #   @param  [Object]          object Anything.
  #   @return [Data::Validator]        Valudator that matches it.
  def new rule
    case rule
    when self  then rule # already
    when Hash  then bare_new isa: Hash,  rule: rule
    when Array then bare_new isa: Array, rule: rule
    else            bare_new isa: rule
    end
  end
end

class Data::Validator
  # (Maybe recursively) constructs a validator.
  #
  # @param       [Hash]       rule         Describes validation rule.
  # @option rule [String]     isa          Class to match.
  # @option rule [<String>]   :xor         ??? (please ask gfx).
  # @option rule [Object]     :default     Default value.
  # @option rule [true,false] :option      Omitable or not.
  # @option rule [true,false] :allow_extra Can have others or not.
  # @option rule [Hash]       :rule        Recursion rule.
  def initialize(**rule)
    @isa  = rule.delete(:isa) or raise ":isa mandatory"
    @rule = rule
    if rule.has_key? :rule then
      case
      when @isa == Hash then
        recur = rule[:rule].each_pair.each_with_object Hash.new do |(k, v), r|
          case v when Hash then
            r[k] = self.class.send :bare_new, v
          else
            r[k] = self.class.send :bare_new, isa: v
          end
        end
        @rule = rule.merge rule: recur
      when @isa == Array then
        recur = rule[:rule].map {|i| self.class.new i }
        @rule = rule.merge rule: recur
      end
    end
  end

  # Validates the input
  #
  # @note this does not modify the validator, but does modify the argument
  #   object.
  #
  # @param  [Object] actual Thing to validate.
  # @return [Object]        The argument, validated and filled defaults.
  def validate actual
    case actual when @isa then
      if @rule.has_key? :rule then
        case
        when @isa == Hash  then return validate_hash actual
        when @isa == Array then return validate_array actual
        else raise "[bug] notreached"
        end
      else
        return actual
      end
    else
      raise "type mismatch"
    end
  end

  protected
  def [] key
    @rule[key]
  end

  def has_key? key
    @rule.has_key? key
  end

  private
  def validate_hash actual
    xor     = Array.new
    missing = Array.new
    @rule[:rule].each_pair do |key, rule|
      if actual.has_key? key then
        begin
          actual[key] = rule.validate actual[key]
        rescue => err
          raise "#{key}:#{err}"
        end
        if exclude = rule[:xor]
          if (actual.keys & exclude).empty?
            xor.concat exclude
          else
            raise "#{key} versus #{exclude.inspect} are exclusive"
          end
        end
      elsif rule.has_key? :default then
        actual[key] = rule[:default]
      elsif rule[:optional] then
        # ok
      elsif @rule[:allow_extra] then
        # ok
      else
        missing << key
      end
    end
    unless missing.empty?
      if (missing | xor) == xor
        raise "#{missing.inspect} missing"
      end
    end
    return actual
  end

  def validate_array actuals
    n = @rule[:rule].length
    m = actuals.length
    if n < m then
      if @rule[:allow_extra] then
        # ok go below
      else
        raise "extra #{m-n} element(s) exist"
      end
    elsif m < n then
      raise "need #{n-m} more element(s)"
    end

    @rule[:rule].each_index do |index|
      begin
        @rule[index].validate actuals[index]
      rescue => err
        raise "##{index}:#{err}"
      end
    end

    return actual
  end
end
