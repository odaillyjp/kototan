RSpec::Matchers.define :have_class do |class_name|
  match do |element|
    element.native['class'].split(/\s/).include?(class_name)
  end
end
