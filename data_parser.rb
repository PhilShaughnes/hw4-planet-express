require 'csv'
require 'pry'


class Delivery
  attr_accessor :destination, :shipped, :num_crates, :profit, :pilot

  def initialize (destination:, what_got_shipped:, number_of_crates:, money_we_made:)
    @destination = destination
    @shipped = what_got_shipped
    @num_crates = number_of_crates.to_i
    @profit = money_we_made.to_i
    @pilot = case destination
            when "Earth" then "Fry"
            when "Mars"  then "Amy"
            when "Uranus" then "Bender"
            else "Leela"
            end
  end

  def +(other)
    @profit + other.profit
  end

end

def trips(data, pilot_name)
  data.select { |ship| ship.pilot.include?(pilot_name) }.length
end

def total_bonus(data, pilot_name)
  data.select{|trip| trip.pilot.include?(pilot_name)}.map{|trip| trip.profit*0.1 }.inject(:+)
end

data = []
CSV.foreach("planet_express_logs.csv", headers: true, header_converters: :symbol) {|row| data << Delivery.new(row)}

total_money = data.map{ |del| del.profit }.inject(:+)

puts trips(data, "Fry")
puts total_bonus(data, "Fry")
