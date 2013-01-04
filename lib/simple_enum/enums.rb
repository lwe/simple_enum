# Load all enums
Dir["#{File.dirname(__FILE__)}/enums/*_enum.rb"].each do |file|
  require file
end
