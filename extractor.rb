require 'rubygems'
require "selenium-webdriver"
require "axlsx"

def find_titles(driver)
  elements = driver.find_elements(:css, "td span a")

  titles = []
  elements.each do |elem|
    titles << elem.text if elem.attribute(:href).include? "citation.cfm"
  end

  # There first three elements are email, RSS and such links, so they can be discarded
  return titles.drop(3)
end

def find_abstracts(driver)
  elements = driver.find_elements(:css, "span")

  abstracts = []
  elements.each do |elem|
    abstracts << elem.find_element(:tag_name, "p").attribute("innerHTML") if elem.attribute(:id).include? "toHide"
  end
  return abstracts
end

def write_txt_output(titles, abstracts, outfile="output.txt")
  f = File.new(outfile, "w")
  0.upto(titles.count - 1).each do |i|
    f.write("#{titles[i]}\n#{abstracts[i]}\n\n")
  end
  f.close
end  

def write_xlsx_output(titles, abstracts, outfile="output.xlsx")
  p = Axlsx::Package.new
  row_number = 1
  p.workbook.add_worksheet(:name => "Papers") do |sheet|
    sheet.add_row ["Title"]
    row_number += 1
    titles.each do |title|
      sheet.add_row [title]
      sheet.add_comment ref: "A#{row_number}", author: "Script", text: abstracts[row_number - 2], hidden: true
      row_number += 1
    end
  end
  p.use_shared_strings = true
  p.serialize(outfile)
end

url = "http://dl.acm.org/citation.cfm?id=2380116&picked=prox&CFID=273518736&CFTOKEN=27221757&preflayout=flat#prox"
outfile = "output.txt"

driver = Selenium::WebDriver.for :firefox
driver.navigate.to url

titles = find_titles(driver)
abstracts = find_abstracts(driver)

write_txt_output(titles, abstracts)
write_xlsx_output(titles, abstracts)

driver.quit