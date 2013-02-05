require 'rubygems'
require "selenium-webdriver"

url = "http://dl.acm.org/citation.cfm?id=2380116&picked=prox&CFID=273518736&CFTOKEN=27221757&preflayout=flat#prox"
outfile = "output.txt"

driver = Selenium::WebDriver.for :firefox
driver.navigate.to url

elements = driver.find_elements(:css, "td span a")

titles = []
elements.each do |elem|
  titles << elem.text if elem.attribute(:href).include? "citation.cfm"
end

# There first three elements are email, RSS and such links, so they can be discarded
titles = titles.drop(3)

elements = driver.find_elements(:css, "span")

abstracts = []
elements.each do |elem|
  abstracts << elem.find_element(:tag_name, "p").attribute("innerHTML") if elem.attribute(:id).include? "toHide"
end

driver.quit

f = File.new(outfile, "w")
0.upto(titles.count - 1).each do |i|
  f.write("#{titles[i]}\n#{abstracts[i]}\n\n")
end
f.close