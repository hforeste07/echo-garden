GardenPlot.destroy_all
Garden.destroy_all
User.destroy_all

# Sample Alice in Wonderland–themed users
characters = [
  { first_name: "Alice", last_name: "Liddell", email: "alice@example.com" },
  { first_name: "Mad Hatter", last_name: "Hatson", email: "mad.hatter@example.com" },
  { first_name: "Cheshire", last_name: "Cat", email: "cheshire.cat@example.com" },
  { first_name: "White", last_name: "Rabbit", email: "white.rabbit@example.com" },
  { first_name: "Queen", last_name: "Hearts", email: "queen.hearts@example.com" },
  { first_name: "March", last_name: "Hare", email: "march.hare@example.com" },
  { first_name: "Tweedle", last_name: "Dee", email: "tweedle.dee@example.com" },
  { first_name: "Tweedle", last_name: "Dum", email: "tweedle.dum@example.com" },
  { first_name: "Caterpillar", last_name: "Absolem", email: "caterpillar@example.com" },
  { first_name: "Dormouse", last_name: "Sleepy", email: "dormouse@example.com" }
]

# Create users first
users_created = characters.map do |char|
  location = Location.order("RANDOM()").first
  # NOTE: This is broken. ActiveRecord::RecordInvalid: Validation failed: Location can't be blank (ActiveRecord::RecordInvalid)
  User.create!(
    first_name: char[:first_name],
    last_name: char[:last_name],
    email: char[:email],
    password: "appdev",
    password_confirmation: "appdev",
    location: location
  )
end

gardens_created = []
plots_created = []

# Fetch all plants once (optional)
plants = Plant.all.to_a

# Now create gardens and plots for each user
users_created.each do |user|
  # Get plants suitable for this user's location
  plants_for_location = Plant.joins(:plant_native_regions)
                             .where(plant_native_regions: { wgsrpd_code: user.location.wgsrpd_code })
                             .distinct
                             .to_a

  # fallback if no plants match
  plants_for_location = Plant.all.to_a if plants_for_location.empty?

  rand(1..2).times do |i|
    rows = [3, 4, 5, 6, 7].sample
    columns = [3, 4, 5, 6, 7].sample
    garden = user.gardens.create!(
      name: "#{user.first_name}'s Garden #{i + 1}",
      rows: rows,
      columns: columns
    )
    gardens_created << garden

    (1..rows).each do |row|
      (1..columns).each do |col|
        plot = garden.garden_plots.create!(
          row: row,
          column: col,
          plant: plants_for_location.sample
        )
        plots_created << plot
      end
    end
  end
end

puts "Seeding complete!"
puts "Users created: #{users_created.count}"
puts "Gardens created: #{gardens_created.count}"
puts "Garden plots created: #{plots_created.count}"
