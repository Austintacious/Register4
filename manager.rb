require 'date'
require 'table_print'
require 'csv'
#require 'Cashier'
 
class Manager
  attr_accessor :gross_sales, :net_profit, :items_sold, :manager_data, :start_date 
 
  def initialize
    @gross_sales = 0.0
    @net_profit = 0.0
    @items_sold = 0
    @manager_data = []
    @start_date = ""
    @totals=[]
  end
 
  def get_input
    @input = gets.chomp
  end
 
  def get_start_date
    puts "Please enter a start date in the following format (DD/MM/YYYY):"
    @start_date = get_input
  end
 
  def get_end_date
    puts "Please enter an end date in the following format (DD/MM/YYYY):"
    get_input
  end
 
  def check_date?
    x.map! { |num| num.to_i }
    Date.valid_date?(x[2],x[0],x[1])
  end
 
  def parse_date
    Date.parse(@input)
  end
 
  def read_csv
    CSV.foreach("report.csv", headers: true) do |row|
      date = Date.parse(row['date'])
      if (@start_date..@input).cover?(date)
        @gross_sales += row['gross_sales'].to_f
        @net_profit += row['net_profit'].to_f
        @items_sold += row['total_items'].to_i
        @manager_data << row
      end
    end 
  end
 
  def valid_start?
    @start_date = Date.parse(@start_date)
    @start_date <= Date.parse(DateTime.now.strftime('%Y-%m-%d'))
  end
 
  def valid_end?
    @input = Date.parse(@input.to_s)
    @input >= @start_date
  end
 
  def check_end
    @input = Date.parse(@input)
    if @input == Date.future?
      @input = Date.parse(DateTime.now.strftime('%Y-%m-%d'))
    end    
  end
 
  def format_number(num)
    sprintf("%.2f",num)
  end
 
  def display_data
    @totals = @gross_sales, @net_profit, @items_sold
    if @totals.reduce(:+) == 0
      puts "No sales data found."
    else
      @manager_data.each do |order|
        i = 0
        while i < @manager_data.length
          puts "Date: #{@manager_data[i][3]} \nTime: #{@manager_data[i][4]} \nItems Sold: #{@manager_data[i][2]} \nGross Sales: #{@manager_data[i][0]} \nNet Profit: #{@manager_data[i][1]}\n \n"
          i += 1
        end
      end
      puts "=======Overall Totals=======
        \nGross Sales: $#{format_number(@totals[0])} \nNet Profit: $#{format_number(@totals[1])} \nItems Sold: #{@totals[2]}"
    end
  end
 
  def display_date_error
    puts "Invalid date. Please enter a vald date."
  end
 
end
 
 class Runner
  def initialize
    x = Manager.new
    x.get_start_date
    x.valid_start?
    x.get_end_date  
    x.valid_end?
        #x.check_end
    x.read_csv
    x.display_data
    #  else
     #   x.display_date_error
      #end
    #else
      #x.display_date_error
    #end
  end
 
 end
 
Runner.new
