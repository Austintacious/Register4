require 'csv'
require 'table_print'
require 'date'
 
class Cashier
  attr_reader :input
  
  def initialize
    @item_name = {}
    @item_sku = {}
    @total = 0
    @total_items = 0
    @net_profit = 0.0
    @menu_display =[]
    @menu =[]
    @item_tracker = {}
    #binding.pry
  end
  
  def display_menu
    puts "Welcome to the Coffee Shop"
    puts "Name    SKU  Price"
    CSV.foreach('coffee_menu.csv', headers: true) do |row|
      name = row['name']
      sku = row['sku']
      retail_price  = row['retail_price']
      @item_sku[row[1]] = [row[0], row[2], row[3]]
      @item_name[row[0]] = [row[1], row[2], row[3]]
      @menu = "#{name} - #{sku} - #{retail_price}"
      puts @menu
      @menu_display << @menu
    end
    #puts @item_sku
    #puts @item_name
  end
  
  def get_input
    @input = gets.chomp
  end
 
  def get_item_entry_value
    puts "Would you like to enter an item by name or SKU? Enter 'done' to check out."
    get_input
  end
 
  def check_entry?
    @input.downcase == "name"
  end
 
  def get_item_by_name
    puts "Please enter the name of the item:"
    @selection = get_input
  end
 
  def get_item_by_sku
    puts "Please enter the SKU of the item:"
    @selection = get_input
  end
 
  def change_input
    @selection = @item_name[@selection][0]
  end
 
 
  def select_amt
    puts "How many?"
    get_input
  end
 
  def display_subtotal
    @total += (@item_sku[@selection][1].to_i * @input.to_i)
    puts "Subtotal: #{format_number(@total)}"
  end
  
  def check_tender?
    unless valid_tender?
      puts "WARNING invalid tender entered. Please try again."
      get_input
      check_tender?
    end
  end
  
  def valid_tender?
    @input.match(/\A\$?\d+(.\d{1,2})?\z/)
  end
 
  def check_done?
    @input.downcase == "done"
  end
 
  def check_amt?
    unless valid_amount?
      puts "WARNING invalid amount entered. Please try again."
      get_input
      check_amt?
    end
  end
 
  def valid_amount?
    @input.match(/\A\d*\z/)
  end
 
  def valid_input?
    @input.match(/\A\d*\.?\d?\d?\z/)
  end
  
  def valid_name?
    @item_name.keys.include?(@selection)
  end
 
  def valid_sku?
    @item_sku.keys.include?(@selection)
  end
 
  def valid_entry?
    @input.downcase == "name" || "sku"
  end
 
  def check_name?
    unless valid_name?
      puts "WARNING invalid item name entered. Please try again."
      @selection = get_input
      check_name?
    end
  end
 
  def check_sku?
    unless valid_sku?
      puts "WARNING invalid sku entered. Please try again."
      @selection = get_input
      check_sku?
    end
  end  
 
  def track_items
    if @item_tracker.has_key?(@selection)
      @item_tracker[@selection] = (@item_tracker[@selection]+ @input.to_i)
    else
      @item_tracker[@selection] = @input.to_i
    end
  end
 
  def calc_change
    (@total - @input.to_f).abs
  end
 
  def format_number(num)
    sprintf("%.2f",num)
  end
 
  def calculate_net_profit(selection, amount)
    @net_profit += ((amount.to_f*(@item_sku[selection][1]).to_f) - (amount.to_f*(@item_sku[selection][2]).to_f))
  end
 
  def display_complete_sale
    puts "===Sale Complete===\n\n\n"
    @item_tracker.each do |selection,amount|
      puts "$#{format_number(amount*@item_sku[selection][1].to_i)} - #{amount} #{@item_sku[selection][0]}"
      @total_items += amount
      #binding.pry
      calculate_net_profit(selection, amount)
    end
    puts "\n\nTotal: $#{format_number(@total)}"
  end
 
  def unsuccessful_checkout
    puts "WARNING: The customer still owes $#{format_number(calc_change)}! Exiting..."
  end
 
  def successful_checkout
    @time = Time.now.strftime('%H:%M:%S')
    @date = DateTime.now.strftime('%Y-%m-%d')
    puts "===Thank You!==="
    print "The total change due is $#{format_number(calc_change)}\n\n"
    puts "#{@time}"
    puts "================"
  end
 
  def checkout
    puts "What is the amount tendered?"
    get_input
    checkout unless valid_input?
    calc_change
    if  @input.to_f >= @total
      successful_checkout
    else
      unsuccessful_checkout
    end   
  end
 
  def update_report
    File.open("report.csv", "a") do |file|
      file.write("\n#{@total},#{@net_profit},#{@total_items},#{@date},#{@time}")
    end
  end
 
end
 
class Runner
  def initialize
    x = Cashier.new
 
    x.display_menu
    x.get_item_entry_value
    until x.check_done?
      if x.valid_entry?
        if x.check_entry? 
          x.get_item_by_name
          x.check_name?
          x.change_input
        else 
          x.get_item_by_sku
          x.check_sku?
        end
      x.select_amt
      x.check_amt?
      x.track_items
      x.display_subtotal
      x.get_item_entry_value
      elsif !x.check_done?
        puts "WARNING! Input not valid, please enter a valid input:"
      end
    end
    x.display_complete_sale
    x.checkout
    x.update_report
  end
 
end
 
Runner.new
