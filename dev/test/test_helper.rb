# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "product_taxonomy"
require "active_support/testing/autorun"
require "minitest/benchmark"
require "minitest/pride"
require "mocha/minitest"

module ActiveSupport
  class TestCase
    teardown do
      ProductTaxonomy::Value.reset
      ProductTaxonomy::Attribute.reset
      ProductTaxonomy::Category.reset
    end
  end
end