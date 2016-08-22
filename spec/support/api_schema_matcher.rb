require "json-schema"

RSpec::Matchers.define :match_schema do |schema|
  match do |candidate|
    schema_directory = File.expand_path("../schemas",  __FILE__)
    schema_path = File.join(schema_directory, schema)
    JSON::Validator.validate!(schema_path, candidate)
  end
end
