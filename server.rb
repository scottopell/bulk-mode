require 'rubygems'
require 'bundler/setup'
Bundler.require(:default, :test, :development)

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
end

def taco_bell
  menu_url = 'http://www.fastfoodmenuprices.com/taco-bell-prices/'
  page = Nokogiri::HTML(open(menu_url))
  menu = []
  page.css('tbody.row-hover tr').collect do |el|
    if el.css('.column-2').text != '' ||
       el.css('.column-1').text == '' ||
       el.css('.column-3').text == ''
      next
    end
    name = el.css('.column-1').text
    price = el.css('.column-3').text[1..-1].to_f
    menu << MenuItem.new(name, price)
  end
  menu
end

get '/' do
  menu = taco_bell
  body = '<h1>Taco Bell</h1>''<ul>'
  menu.each { |item| body << item.to_html }
  body << '</ul>'
end
