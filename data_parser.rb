#!/usr/bin/env ruby
require 'csv'
# require 'pry'

=begin
Explorer Mode

Good news Rubyists!
We have a week of records tracking what we shipped at Planet Express. I need you to answer a few questions for Hermes.

1.1 How much money did we make this week?
1.2 How much of a bonus did each employee get? (bonuses are paid to employees who pilot the Planet Express)
1.3 How many trips did each employee pilot?
1.4 Define and use your Delivery class to represent each shipment
Different employees have favorite destinations they always pilot to

Fry - pilots to Earth (because he isn't allowed into space)
Amy - pilots to Mars (so she can visit her family)
Bender - pilots to Uranus (teeheee...)
Leela - pilots everywhere else because she is the only responsible one
They get a bonus of 10% of the money for the shipment as the bonus

Adventure Mode

2.1 Define a class "Parse", with a method parse_data, with an argument file_name that handles output to the console
2.2 How much money did we make broken down by planet? ie. how much did we make shipping to Earth? Mars? Saturn? etc.
Epic Mode

3.1 No puts or print's in any method
3.2 No methods longer than 10 lines long
3.3 Make data_parser.rb executable with a command line argument of the file name
./data_parser.rb planet_express_logs.csv

Legendary Mode

4.1 All the above questions should have corresponding class methods in Parse
4.2 If the script is called with a report argument (as in: ./data_parser.rb planet_express_logs.csv report), the script saves a new CSV file in the current directory with payroll information in the format of: Pilot, Shipments, Total Revenue, Payment
=end
class Delivery #1.4
  attr_accessor :destination, :shipped, :num_crates, :profit, :pilot

  def initialize(destination:, what_got_shipped:, number_of_crates:, money_we_made:)
    @destination = destination
    @shipped = what_got_shipped
    @num_crates = number_of_crates.to_i
    @profit = money_we_made.to_i
    @pilot = sort_pilot(destination)
  end

  # This used to be in the initialization method. Moved here to stay <10 lines per method.
  def sort_pilot(destination)
    case destination
    when 'Earth' then 'Fry'
    when 'Mars'  then 'Amy'
    when 'Uranus' then 'Bender'
    else 'Leela'
    end
  end

  def +(other)
    @profit + other.profit
  end

  def coerce(other)
    [profit, other]
  end
end

class Parse #2.1
  attr_accessor :file, :total_money, :pilots, :planets

  def initialize(new_file = nil)
    @file = []
    @pilots = []
    @planets = []
    parse_data(new_file) if new_file
  end

  def parse_data(file_name)
    CSV.foreach(file_name, headers: true, header_converters: :symbol) { |row| file << Delivery.new(row) }
    self.total_money = file.inject(:+) #1.1
    self.pilots = parse_pilots
    self.planets = parse_planets
    file
  end

  # creates an array of hashes. One hash for each pilot and all his/her info
  def parse_pilots #1.2, 1.3
    file.map(&:pilot).uniq.map do |pilot|
      { pilot: pilot, shipments: shipments(pilot), total_revenue: total_revenue(pilot), payment: total_revenue(pilot) * 0.1 }
    end
  end

  # These two methods are just one line each, so they could be put inside
  # the parse_pilots method, but this seemed cleaner and more readable.
  def total_revenue(pilot_name)
    file.select { |ship| ship.pilot == pilot_name }.inject(0, :+)
  end

  def shipments(pilot_name)
    file.select { |ship| ship.pilot == pilot_name }.length
  end

  # this could have been done with a single key pair in each hash,
  # but this way seemed better since it was consistent with the way
  # pilots were handled...that and using group_by wasn't as simple
  # as I had hoped.
  def parse_planets #2.2
    file.map(&:destination).uniq.map do |planet|
      { planet: planet, profit: planet_profit(planet) }
    end
  end

  def planet_profit(planet)
    file.select { |ship| ship.destination == planet }.inject(0, :+)
  end
end

# not sure if the || is needed. If data_parser.rb is run it just auto
# loads this file.
planetlog = Parse.new(ARGV[0] || 'planet_express_logs.csv')

# prints to the command line unless the 'report' command is given.
# If it is, a report.csv is generated
if ARGV[1] == 'report' #4.2
  CSV.open('report.csv', 'w  ') do |csv|
    csv << ['Pilot', 'Shipments', 'Total Revenue', 'Payment']
    planetlog.pilots.each { |data| csv << [data[:pilot], data[:shipments], data[:total_revenue], data[:payment]] }
  end

# using printf allows output so it looks like the generated csv file.
else
  printf("%-8s %8s\n", 'PLANET', 'PROFIT')
  puts '--------------------'
  planetlog.planets.each { |data| printf("%-8s %10.2f\n", data[:planet], data[:profit]) }

  printf("\n%-6s %10s %10s %10s\n", 'PILOT', 'SHIPMENTS', 'REVENUE', 'PAYMENT')
  puts '---------------------------------------'
  planetlog.pilots.each { |data| printf("%-6s %10d %10.2f %10.2f\n", data[:pilot], data[:shipments], data[:total_revenue], data[:payment]) }

  puts "\nTOTAL PROFIT THIS WEEK: $#{planetlog.total_money}"
end
