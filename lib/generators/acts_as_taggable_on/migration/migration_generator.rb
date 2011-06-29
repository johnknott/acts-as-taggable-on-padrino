class TestGenerator < Thor::Group
  
  puts ">> loaded #{__FILE__}"

  # register with Padrino
  Padrino::Generators.add_generator(:test_generator, self)
  
  include Thor::Actions
  include Padrino::Generators::Actions
  include Padrino::Generators::Components::Actions

  desc 'My test generator'

  argument :name, :desc => "The name of your xyz"

  require_arguments!

  def generate_something_useful
    # provide implementation here...
  end

end