class SalesQiProfileInformation::FetchInfo

  def get_data
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--ignore-cerfiticate-errors')
    options.add_argument('--disable-popup-blocking')
    options.add_argument('--disable-translate')

    @driver = Selenium::WebDriver.for :chrome, options: options
    @profile = "https://app.salesql.com/dashboard/contacts?keywords=protonshub"
    login
  end

  def login
    @driver.navigate.to("https://app.salesql.com/accounts/login")
    # start login process by entering username
    puts "[INFO]: Entering username"
    wait = Selenium::WebDriver::Wait.new(:timout => 10)
    wait.until {@driver.find_element(:xpath, "//button['@class=linkedin-signin-button']")}

    @driver.find_element(:xpath, "//button['@class=linkedin-signin-button']").click
    wait = Selenium::WebDriver::Wait.new(:timout => 10)
    wait.until {@driver.find_element(:name, "session_key")}

    @driver.find_element(:name, "session_key").send_keys("rachitverma.001@gmail.com")

    puts "[INFO]: Entering password"
    @driver.find_element(:name, "session_password").send_keys("gmail8871338693")
    # then we'll click the login button
    puts "[INFO]: Logging in"
    @driver.find_element(:xpath, "//button").click


    company_data
  end

  def company_data
    puts "[INFO]: Navigating to profile #{@profile}"
    wait = Selenium::WebDriver::Wait.new(:timout => 10)
    wait.until {@driver.find_element(:css, "div.dashboard-layout")}
    @driver.navigate.to(@profile)

    puts "[INFO]: Scraping data"
    wait = Selenium::WebDriver::Wait.new(:timout => 10)
    wait.until {@driver.find_element(:css, "div.dashboard-layout")}

    payload = get_payload

    puts "[DONE]:"
    sleep(2)
    @driver.quit
    payload
  end

  def get_payload
    doc = Nokogiri::HTML(@driver.page_source)
    items = doc.css('tr.table-row')
    founders_data = []
    employee_data = []

    items.each do |item|
      designation = item.css('div.primary-job-title')&.first&.text
        data = {
          name:item.css("span.name")&.first&.text,
          designation: designation,
          image: item.css('img')&.first['src'],
          email: item.css('p.contact-info-item')&.first&.text&.split[1],
          phone: item.css('p.contact-info-item')[1]&.text&.split[1],
          skills: item.css('div.skill')&.first&.text,
          education: item.css('p.education')&.first&.text&.gsub("\n","")&.strip,
          country: item.css('div.location-info')&.first&.text&.gsub("\n","")&.strip,
          city:item.css('div.location-info')&.text&.strip&.gsub(" ","")&.split("\n")[2],
          state:item.css('div.location-info')&.text&.strip&.gsub(" ","")&.split("\n")[4]
        }

      if designation.include? "Chief"
        founders_data << data
      else
        employee_data << data
      end
    end

    { founders_data:founders_data, employee_data:employee_data}
  end


end