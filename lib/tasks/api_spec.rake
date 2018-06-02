namespace :api_spec do
  desc 'Create OpenAPI Specification'
  task :create => :environment do
    puts "Creating..."
    OpenApiAnnotator.create_spec_yaml
    puts "Created.✨"
  end
end

task :api_spec do
  Rake::Task["api_spec:create"].invoke
end
