#!/usr/bin/env ruby
require 'csv'
require 'pry'

class Delivery
  attr_accessor :destination, :shipped, :num_crates, :profit, :pilot

  def initialize (destination:, what_got_shipped:, number_of_crates:, money_we_made:)
    @destination = destination
    @shipped = what_got_shipped
    @num_crates = number_of_crates.to_i
    @profit = money_we_made.to_i
    @pilot = sort_pilot(destination)
  end

  def sort_pilot(destination)
    case destination
      when "Earth" then "Fry"
      when "Mars"  then "Amy"
      when "Uranus" then "Bender"
      else "Leela"
    end
  end

  def +(other)
    @profit + other.profit
  end

  def coerce(other)
    [self.profit, other]
  end

end

class Parse
  attr_accessor :file, :total_money, :pilots, :planets

  def initialize(new_file=nil)
    @file = []
    @pilots = []
    @planets = []
    parse_data(new_file) if new_file
  end

  def parse_data(file_name)
      CSV.foreach(file_name, headers: true, header_converters: :symbol) {|row| file << Delivery.new(row)}
      self.total_money = file.inject(:+)
      self.pilots = parse_pilots
      self.planets = parse_planets
      file
  end

  def parse_pilots
    file.map{|ship| ship.pilot}.uniq.map do |pilot|
      {pilot: pilot, shipments: shipments(pilot), total_revenue: total_revenue(pilot), payment: total_revenue(pilot)*0.1}
    end
  end

  def total_revenue(pilot_name)
    file.select{|ship| ship.pilot == pilot_name}.inject(0,:+)
  end

  def shipments(pilot_name)
    file.select { |ship| ship.pilot == pilot_name }.length
  end

  def parse_planets
    file.map{|ship| ship.destination}.uniq.map do |planet|
        {planet: planet, profit: planet_profit(planet)}
    end
  end

  def planet_profit(planet)
    file.select {|ship| ship.destination == planet }.inject(0,:+)
  end
end

planetlog = Parse.new(ARGV[0] || "planet_express_logs.csv")

if ARGV[1]== "report"
  

else
  puts "\nPLANET DATA:\n"
  puts planetlog.planets.map{|data| "Shipments to #{data[:planet]} made $#{data[:profit]} this week."}
  puts"\nPILOT DATA:\n"
  puts planetlog.pilots.map{|data| "Pilot #{data[:pilot]} brought in #{data[:shipments]} shipments, making a total of $#{data[:total_revenue]}, and earning $#{data[:payment]} in bonuses."}
  puts "\nTOTAL PROFIT THIS WEEK: $#{planetlog.total_money}"
end
