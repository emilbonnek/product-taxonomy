# frozen_string_literal: true

require "thor"
require "active_support/all"
require "active_model"
require_relative "product_taxonomy/cli"
require_relative "product_taxonomy/models/model_index"
require_relative "product_taxonomy/models/attribute"
require_relative "product_taxonomy/models/extended_attribute"
require_relative "product_taxonomy/models/value"
require_relative "product_taxonomy/models/category"
require_relative "product_taxonomy/models/taxonomy"