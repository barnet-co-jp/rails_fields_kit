# frozen_string_literal: true

class SearchableMatchSpecRelation
  attr_reader :where_args, :limit_value

  def initialize
    @where_args = []
  end

  def where(*args)
    @where_args << args
    self
  end

  def limit(value)
    @limit_value = value
    []
  end
end

class SearchableMatchSpecPredicate
  attr_reader :parts

  def initialize(*parts)
    @parts = parts
  end

  def or(other)
    self.class.new(:or, self, other)
  end
end

class SearchableMatchSpecColumn
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def matches(value)
    SearchableMatchSpecPredicate.new(:matches, name, value)
  end
end

class SearchableMatchSpecArelTable
  def [](name)
    SearchableMatchSpecColumn.new(name)
  end
end

class SearchableMatchSpecModel
  class << self
    attr_accessor :last_relation
  end

  def self.all
    self.last_relation = SearchableMatchSpecRelation.new
  end

  def self.arel_table
    SearchableMatchSpecArelTable.new
  end

  def self.sanitize_sql_like(value)
    value.to_s.gsub("%", "\\%")
  end
end

class SearchableMatchSpecContainsController
  include RailsFieldsKit::Searchable

  attr_accessor :params
  attr_reader :rendered_json

  rfk_search_with(
    model: SearchableMatchSpecModel,
    value: :id,
    label: :name,
    search: [:name, :email]
  )

  def render(json:, status: :ok)
    @rendered_json = json
  end
end

class SearchableMatchSpecPrefixController
  include RailsFieldsKit::Searchable

  attr_accessor :params

  rfk_search_with(
    model: SearchableMatchSpecModel,
    value: :id,
    label: :name,
    search: [:name, :email],
    match: :prefix
  )

  def render(json:, status: :ok)
  end
end

class SearchableMatchSpecExactController
  include RailsFieldsKit::Searchable

  attr_accessor :params

  rfk_search_with(
    model: SearchableMatchSpecModel,
    value: :id,
    label: :name,
    search: [:name, :email],
    match: :exact
  )

  def render(json:, status: :ok)
  end
end

RSpec.describe "RailsFieldsKit::Searchable match strategies" do
  def predicate_patterns(predicate)
    return [] unless predicate

    type, left, right = predicate.parts
    if type == :or
      predicate_patterns(left) + predicate_patterns(right)
    else
      [right]
    end
  end

  def search_patterns_for(controller_class, query)
    controller = controller_class.new
    controller.params = { "q" => query }
    controller.index
    predicate_patterns(SearchableMatchSpecModel.last_relation.where_args.fetch(0).fetch(0))
  end

  it "keeps contains matching as the default" do
    expect(search_patterns_for(SearchableMatchSpecContainsController, "Acme")).to eq(["%Acme%", "%Acme%"])
  end

  it "supports prefix matching" do
    expect(search_patterns_for(SearchableMatchSpecPrefixController, "Acme")).to eq(["Acme%", "Acme%"])
  end

  it "supports exact matching" do
    expect(search_patterns_for(SearchableMatchSpecExactController, "Acme")).to eq(["Acme", "Acme"])
  end

  it "keeps SQL LIKE escaping before applying the match strategy" do
    expect(search_patterns_for(SearchableMatchSpecPrefixController, "A%")).to eq(["A\\%%", "A\\%%"])
  end

  it "rejects unsupported match strategies at definition time" do
    expect do
      Class.new do
        include RailsFieldsKit::Searchable

        rfk_search_with(
          model: SearchableMatchSpecModel,
          value: :id,
          label: :name,
          search: :name,
          match: :suffix
        )
      end
    end.to raise_error(ArgumentError, /Unsupported rfk_search_with match strategy/)
  end
end
