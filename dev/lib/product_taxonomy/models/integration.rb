# frozen_string_literal: true

module ProductTaxonomy
  # A single integration, e.g. "shopify", containing all versions of that integration.
  class Integration
    INTEGRATIONS_PATH = File.expand_path("integrations", ProductTaxonomy::DATA_PATH)

    class << self
      # Generate all distribution files for all integrations.
      #
      # @param output_path [String] The path to the output directory.
      # @param logger [Logger] The logger to use for logging messages.
      # @param current_shopify_version [String] The current version of the Shopify taxonomy.
      # @param base_path [String] The path to the base directory containing integration versions.
      def generate_all_distributions(output_path:, logger:, current_shopify_version: nil, base_path: INTEGRATIONS_PATH)
        integrations = load_all_from_source(current_shopify_version:, base_path:)
        all_mappings = integrations.map(&:versions).flatten.each_with_object([]) do |integration_version, all_mappings|
          logger.info("Generating integration mappings for #{integration_version.name}/#{integration_version.version}")
          integration_version.generate_distributions(output_path:)
          all_mappings.concat(integration_version.to_json(direction: :both))
        end
        generate_all_mappings_file(mappings: all_mappings, current_shopify_version:, output_path:)
      end

      # Load all integration versions from the source data directory.
      #
      # @return [Array<IntegrationVersion>]
      def load_all_from_source(current_shopify_version: nil, base_path: INTEGRATIONS_PATH)
        integrations_yaml = YAML.safe_load_file(File.expand_path("integrations.yml", base_path))
        integrations_yaml.map do |integration_yaml|
          name = integration_yaml["name"]
          versions = integration_yaml["available_versions"].map do |integration_version|
            integration_path = File.expand_path(integration_version, base_path)
            IntegrationVersion.load_from_source(integration_path:, current_shopify_version:)
          end

          if name == "shopify"
            versions.each_cons(2).reverse_each do |previous_version, next_version|
              previous_version.remap_shopify_mappings_against(next_version)
            end
          end

          new(name:, versions:)
        end
      end

      # Generate a JSON file containing all mappings for all integration versions.
      #
      # @param mappings [Array<Hash>] The mappings to include in the file.
      # @param version [String] The current version of the Shopify taxonomy.
      # @param output_path [String] The path to the output directory.
      def generate_all_mappings_file(mappings:, current_shopify_version:, output_path:)
        File.write(
          File.expand_path("all_mappings.json", integrations_output_path(output_path)),
          JSON.pretty_generate(to_json(mappings:, current_shopify_version:)) + "\n",
        )
      end

      # Generate the path to the integrations output directory.
      #
      # @param base_output_path [String] The base path to the output directory.
      # @return [String]
      def integrations_output_path(base_output_path)
        File.expand_path("en/integrations", base_output_path)
      end
    end

    attr_reader :name, :versions

    def initialize(name:, versions:)
      @name = name
      @versions = versions
    end
  end
end
