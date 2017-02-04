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

  def *(other)# why does this work for *, but not +?
    other.class== Delivery ? @profit*other.profit : @profit*other
  end

  def coerce(other) #why is this necessary for + but not *?
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
      #self.pilots = parse_pilots
      #self.planets = parse_planets
      file
  end

  def parse_pilots
    file.map{|ship| ship.pilot}.uniq.map do |pilot|
      {pilot: pilot, bonus_earned: total_bonus(pilot), trips: trips(pilot)}
    end
  end

  def total_bonus(pilot_name)
    file.select{|ship| ship.pilot == pilot_name}.inject(:+)*0.1
  end

  def trips(pilot_name)
    file.select { |ship| ship.pilot == pilot_name }.length
  end

  def parse_planets
    file.map{|ship| ship.destination}.uniq.map do |planet|
        {planet: planet, profit: planet_profit(planet)}
    end
  end

  def parse_planets2 #can I do this with group_by? or even inject?
    file.group_by{|ship| ship.destination}.each_value{|v| v.inject(0,:+)}
  end

  def planet_profit(planet)
    file.select {|ship| ship.destination == planet }.inject(0,:+)
  end


end





data = []
CSV.foreach("planet_express_logs.csv", headers: true, header_converters: :symbol) {|row| data << Delivery.new(row)}

#total_money = data.map{ |del| del.profit }.inject(:+)
puts total_money = data.inject(:+)



planetlog = Parse.new
planetlog.parse_data("planet_express_logs.csv")
puts planetlog.trips("Fry")
puts planetlog.parse_planets.inspect
puts planetlog.parse_pilots.inspect
