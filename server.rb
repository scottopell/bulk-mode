require 'rubygems'
require 'bundler/setup'
Bundler.require(:default, :test, :development)

def taco_bell
  menu_url = 'http://www.fastfoodmenuprices.com/taco-bell-prices/'
  page = Nokogiri::HTML(open(menu_url))
  menu = {}
  page.css('tbody.row-hover tr').collect do |el|
    if el.css('.column-2').text != '' ||
       el.css('.column-1').text == '' ||
       el.css('.column-3').text == ''
      next
    end
    price = el.css('.column-3').text[1..-1].to_f
    menu[el.css('.column-1').text] = price
  end
  menu
end

get '/hello' do
  "world"
end

get '/' do
  menu = taco_bell
  body = '<ul>'
  menu.each { |item, price| body << "<li>#{item} $#{price}</li>" }
  body << '</ul>'
end
