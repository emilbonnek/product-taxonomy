# frozen_string_literal: true

class NewDataCategoryCommand < ApplicationCommand
  usage do
    no_command
  end

  keyword :name do
    desc "Category name to create"
    required
  end

  keyword :parent do
    desc "Parent category ID"
    required
  end

  option :id do
    desc "ID for the created category. Inferred if not specified"
    short "-i"
    long "--id string"
    validate { _1 =~ Category::ID_REGEX }
  end

  def execute
    frame("Adding new category") do
      find_parent!
      validate_id!
      create_category!
      update_vertical_file!
    end
  end

  private

  def find_parent!
    @parent = Category.find_by(id: params[:parent])
    return @parent if @parent

    logger.fatal("Parent category `#{params[:parent]}` not found")
    exit(1)
  end

  def validate_id!
    params[:id] ||= @parent.next_child_id
    return if params[:id].start_with?(params[:parent])

    logger.fatal("ID `#{params[:id]}` does not start with parent ID `#{params[:parent]}`")
    exit(1)
  end

  def create_category!
    spinner("Creating category") do |sp|
      @new_category = Category
        .create_with(id: params[:id])
        .find_or_create_by!(
          name: params[:name],
          parent: params[:parent],
        )
      sp.update_title("Created category `#{@new_category.name}` with id=`#{@new_category.id}`")
    end
  end

  def update_vertical_file!
    spinner("Updating vertical file") do |sp|
      vertical = @new_category.root
      sys.write_file!("data/categories/#{vertical.handleized_name}.yml") do |file|
        file.write(vertical.as_json_for_data_with_descendants.to_yaml)
      end
      sp.update_title("Updated vertical `#{vertical.name}`")
    end
  end
end