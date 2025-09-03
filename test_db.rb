#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'config/environment'

puts 'Testing database connection...'
puts "Database: #{ActiveRecord::Base.connection.current_database}"

puts "\nTesting models..."
begin
  puts "Breed count: #{Breed.count}"
  puts "Vaccine count: #{Vaccine.count}"
  puts "Pet count: #{Pet.count}"
  puts "User count: #{User.count}"
  puts "Household count: #{Household.count}"
  puts 'All models loaded successfully!'
rescue StandardError => e
  puts "Error: #{e.message}"
  puts e.backtrace.first(5)
end

puts "\nTesting migrations..."
begin
  pending = ActiveRecord::Base.connection.migration_context.needs_migration?
  puts "Pending migrations: #{pending}"
rescue StandardError => e
  puts "Migration error: #{e.message}"
end
