require 'rubygems'
require 'bundler/setup'
Bundler.require(:default, :test, :development)

class TacoBell
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
      price = el.css('.column-3').text[1..-1].to_f
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
end

class MenuItem
  def initialize name, price, calories=nil, protein=nil
    @name = name
    @price = price
    @calories = calories
    @protein = protein
  end

  def to_html
    "<li>#{@name} - $#{@price} | #{@calories} | #{@protein} </li>"
  end

  def get_nutritional_info
    menu_url = 'http://www.tacobell.com/nutrition/information'
    @@jarow = FuzzyStringMatch::JaroWinkler.create( :native )
    @@page ||= Nokogiri::HTML(open(menu_url))
    @@page.css('table#nutrInfo tr').each do |el|
      if @@jarow.getDistance(el.css('th').text, @name) >= 0.8
        @calories = el.css('td:eq(2)').text
        @protein =  el.css('td:eq(12)').text
        return
      end
    end
  end
end


get '/' do
  body = '<h1>Taco Bell</h1>''<ul>'
  body << '<li> NAME - PRICE | CALORIES | PROTEIN</li>'
  TacoBell.menu.each { |item| body << item.to_html }
  body << '</ul>'
end
