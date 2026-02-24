# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Clear out old sample users and gardens if needed
# db/seeds.rb

# Clear old data if needed
GardenPlot.destroy_all
Garden.destroy_all
User.destroy_all

# Sample users
characters = [
  { first_name: "Alice", last_name: "Liddell", email: "alice@example.com" },
  { first_name: "Mad Hatter", last_name: "Hatson", email: "mad.hatter@example.com" },
  # ... add more
]

characters.each do |char|
  location = Location.order("RANDOM()").first

  user = User.create!(
    first_name: char[:first_name],
    last_name: char[:last_name],
    email: char[:email],
    password: "password123",
    password_confirmation: "password123",
    location: location
  )

  # Create 2 gardens per user with different sizes
  2.times do |i|
    rows = rand(3..5)
    columns = rand(3..5)
    garden = user.gardens.create!(
      name: "#{user.first_name}'s Garden #{i+1}",
      rows: rows,
      columns: columns,
      favorite: i == 0 # first garden is default favorite
    )

    # Generate plots for each garden
    rows.times do |r|
      columns.times do |c|
        garden.garden_plots.create!(
          row: r,
          column: c
        )
      end
    end
  end
end
