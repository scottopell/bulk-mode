require 'rubygems'
require 'bundler/setup'
Bundler.require(:default, :test, :development)

class TacoBell
  INDIANA_STATE_TAX = 1.07
  include Singleton

  def self.populate_menu
    menu_url = 'http://www.fastfoodmenuprices.com/taco-bell-prices/'
    @page = Nokogiri::HTML(open(menu_url))
    @menu = []

    @page.css('tbody.row-hover tr').collect do |el|
      if el.css('.column-2').text != '' ||
         el.css('.column-1').text == '' ||
         el.css('.column-3').text == ''
        next
      end
      name = el.css('.column-1').text
      price = el.css('.column-3').text[1..-1].to_f * INDIANA_STATE_TAX
      mi = MenuItem.new(name, price)
      mi.get_nutritional_info
      @menu << mi
    end
    @last_repopulate = Time.now.to_i

    @menu
  end

  def self.menu
    if @last_repopulate.nil? || @menu.nil? ||
       (Time.now.to_i - @last_repopulate) > 3600
      populate_menu
    end
    @menu
  end

  def self.best_for wallet, criteria=:calories
    running_total = 0.00
    sack = []
    if @menu.nil?
      populate_menu
    end

    sorted = @menu.select{ |mi| !mi.send(criteria).nil? }.sort_by{ |mi| mi.send(criteria) }.reverse

    sorted.each do |mi|
      while (running_total + mi.price) < wallet do
        sack << mi
        running_total += mi.price
      end
    end
    sack
  end
end

class MenuItem
  attr_accessor :name, :price, :calories, :protein

  def initialize name, price, calories=nil, protein=nil
    @name = name
    @price = price
    @calories = calories
    @protein = protein
  end

  def to_html
    price = sprintf("%01.2f", @price)
    "<tr><td>#{@name}</td><td>$#{price}</td><td>#{@calories}</td><td>#{@protein}</td></tr>"
  end

  def get_nutritional_info
    menu_url = 'http://www.tacobell.com/nutrition/information'
    @@jarow = FuzzyStringMatch::JaroWinkler.create( :native )
    @@page ||= Nokogiri::HTML(open(menu_url))
    @@page.css('table#nutrInfo tr').each do |el|
      if @@jarow.getDistance(el.css('th').text, @name) >= 0.8
        @calories = el.css('td:eq(2)').text.to_i
        @protein =  el.css('td:eq(12)').text.to_i
        return
      end
    end
  end
end


get '/' do
  body = '<h1>Taco Bell</h1>'
  body << '<table>'
  body << '<thead><td>NAME</td><td>PRICE</td><td>CALORIES</td><td>PROTEIN</td></thead>'
  body << '<tbody>'
  TacoBell.menu.each { |item| body << item.to_html }
  body << '</tbody>'
  body << '</table>'
end

get '/best_for' do
  wallet_amount     = params[:wallet].to_f
  wallet_amount_str = sprintf "%01.2f", wallet_amount
  criteria          = (params[:criteria] || 'calories').to_sym

  body = '<h1>Taco Bell</h1>'
  body << "<h3>Best for $#{wallet_amount_str}</h3>"
  body << '<table>'
  body << '<thead><td>NAME</td><td>PRICE</td><td>CALORIES</td><td>PROTEIN</td></thead>'
  body << '<tbody>'
  TacoBell.best_for(wallet_amount, criteria).each { |item| body << item.to_html }
  body << '</tbody>'
  body << '</table>'
end

get '/favicon.ico' do
  File.read('favicon.ico')
end
