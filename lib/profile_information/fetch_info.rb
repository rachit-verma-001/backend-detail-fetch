class ProfileInformation::FetchInfo

  def get_data(name, profile, company)
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--ignore-cerfiticate-errors')
    options.add_argument('--disable-popup-blocking')
    options.add_argument('--disable-translate')
    @driver = Selenium::WebDriver.for :chrome, options: options

    @name = name
    @profile = profile
    @company  = company
    login
  end

  def login

    @driver.navigate.to("https://www.linkedin.com/login")
    puts "[INFO]: Entering username"
    @driver.find_element(:name, "session_key").send_keys("kushal@ausavi.com")
    puts "[INFO]: Entering password"
    @driver.find_element(:name, "session_password").send_keys("Punjab2017@")
    puts "[INFO]: Logging in"
    @driver.find_element(:xpath, "//button").click
    # sleep(3)
    wait = Selenium::WebDriver::Wait.new(:timout => 10)
    wait.until {@driver.find_element(:css, "body.ember-application")}
    company_data
  end

  def company_data
    puts "[INFO]: Navigating to profile #{@profile}"
    @driver.navigate.to(@profile)
    wait = Selenium::WebDriver::Wait.new(:timout => 10)
    wait.until {@driver.find_element(:css, "div.organization-outlet")}
    puts "[INFO]: Scraping data"
    doc = Nokogiri::HTML(@driver.page_source)

    name = doc.css("h1 span[dir=ltr]")
    name = name ? name.text : nil
    p "b name=#{name}"

    tagline = doc.css("p.org-top-card-summary__tagline")
    p "b tagline1=#{tagline}"
    tagline = tagline ? tagline&.text&.strip : nil
    p "b tagline2=#{tagline}"

    description = doc.css("div.org-top-card-summary-info-list__info-item")
    p "b desc1=#{description}"

    description_content = description ? description&.text&.split("\n")[1]&.strip : nil
    p "b desc2=#{description}"

    city = description ? description&.text&.split("\n")[3]&.strip : nil
    p "b city=#{city}"

    followers = description ? description&.text&.split("\n")[5]&.strip : nil
    p "followers=#{followers}"
    no_of_employees = doc.css("span.org-top-card-secondary-content__see-all")
    p "b employees1=#{no_of_employees}"

    no_of_employees = no_of_employees ? no_of_employees&.text&.strip : nil
    p "b employees2=#{no_of_employees}"

    logo = doc.css("div.org-top-card-primary-content__logo-container img")&.first["src"]
    p "b logo=#{logo}"

    @count = 0

    founders = []
    founders << get_founders('ceo')
    founders << get_founders('coo')
    founders <<  get_founders('cto')

    employers_data= get_employee_data

    payload = {
      name: @name,
      tagline: tagline,
      description: description_content,
      city: city,
      followers: followers,
      no_of_employees: no_of_employees,
      logo: logo,
      founders_count: founders&.count,
      url: @profile
    }
    @company.update(payload)
    puts "[DONE]:"
    sleep(2)
    @driver.quit
    employees = @company.employee_details
    {
      company_detail:@company,
      founder_details: employees.where(role_id:Role.find_by(name:"Founder").id),
      employee_details: employees.where(role_id:Role.find_by(name:"Employee").id)
    }
  end

  def get_founders(post)

    p "inside founders"
    @driver.navigate.to("#{@profile}/?keywords=#{post}")
    sleep(2)
    doc = Nokogiri::HTML(@driver.page_source)

   p "navigated founders"
    names = []
    doc.css('ul.display-flex').each do |founder|
      designation = founder.css("div.lt-line-clamp--multi-line")&.text&.strip
      p "designation = #{designation}"
      if designation.present?
        name=founder.css("div.org-people-profile-card__profile-title")&.text&.strip
        p "name=#{name}"
        names << name
      end
    end

    p "================================="
    names.each do |name|
      p "inside name = #{name}"

      @driver.find_element(:xpath,"//div[@class='org-people-profile-card__profile-title t-black lt-line-clamp lt-line-clamp--single-line ember-view'][contains(.,'#{name}')]")&.click
      doc = Nokogiri::HTML(@driver.page_source)

      city = doc.css(:xpath,"//span[@class='text-body-small inline t-black--light break-words']")&.text&.strip
      p "city = #{city}"
      description = doc.css(:xpath, "//div[contains(@class,'text-body-medium break-words')]")&.text&.strip
      p "description = #{description}"
      designation = description
      p "designation = #{designation}"
      image = doc.css(:xpath,"//img[contains(@width,'200')]")&.text
      p "image = #{image}"

      @driver.find_element(:xpath, "//a[contains(.,'Contact info')]")&.click
      sleep(2)
      doc = Nokogiri::HTML(@driver.page_source)

      mobile = doc.css(:xpath,"//span[@class='t-14 t-black t-normal']")&.text&.strip
      p "mobile = #{mobile}"
      email =  doc.css(:xpath,"//a[@class='pv-contact-info__contact-link link-without-visited-state t-14']")&.text&.split[1] || "#{name&.split[0]&.downcase}.#{name&.split[1]&.downcase}@protonshub.in"
      p "email=#{email}"
      payload = {
        first_name: name&.split()[0],
        last_name: name&.split()[1],
        city: city,
        # description: description,
        email:email,
        mobile_no:mobile,
        designation: designation,
        image: image,
        role_id:Role.find_by(name:'Founder').id
      }
      p "payoad = #{payload}"

      @company.employee_details.create!(payload) unless @company.employee_details.where(first_name:payload[:first_name], last_name:payload[:last_name], email:payload[:email]).first.present?

      @driver.navigate.to("#{@profile}/people/?keywords=#{post}")
      sleep(2)
      doc = Nokogiri::HTML(@driver.page_source)

    end
    names
  end


  def get_employee_data

    p "inside empoyees"
    @driver.navigate.to("#{@profile}")
    sleep(2)
    doc = Nokogiri::HTML(@driver.page_source)

    p "navigated employees"

    names = doc.css("div.org-people-profile-card__profile-title")&.text.split("\n")&.reject(&:blank?)&.collect(&:strip)
    p "================================="
    names.each do |name|
      p "inside name = #{name}"
      @driver.find_element(:xpath,"//div[@class='org-people-profile-card__profile-title t-black lt-line-clamp lt-line-clamp--single-line ember-view'][contains(.,'#{name}')]")&.click
      doc = Nokogiri::HTML(@driver.page_source)

      city = doc.css(:xpath,"//span[@class='text-body-small inline t-black--light break-words']")&.text&.strip
      p "city = #{city}"
      description = doc.css(:xpath, "//div[contains(@class,'text-body-medium break-words')]")&.text&.strip
      p "description = #{description}"
      designation = description
      p "designation = #{designation}"
      image = doc.css(:xpath,"//img[contains(@width,'200')]")&.text
      p "image = #{image}"

      @driver.find_element(:xpath, "//a[contains(.,'Contact info')]")&.click
      sleep(2)
      doc = Nokogiri::HTML(@driver.page_source)

      mobile = doc.css(:xpath,"//span[@class='t-14 t-black t-normal']")&.text&.strip
      p "mobile = #{mobile}"
      email =  doc.css(:xpath,"//a[@class='pv-contact-info__contact-link link-without-visited-state t-14']")&.text&.split[1] || "#{name&.split[0]&.downcase}.#{name&.split[1]&.downcase}@protonshub.in"
      p "email=#{email}"
      payload = {
        first_name: name&.split()[0],
        last_name: name&.split()[1],
        city: city,
        # description: description,
        email:email,
        mobile_no:mobile,
        designation: designation,
        image: image,
        role_id:Role.find_by(name:'Employee')&.id
      }
      p "payoad = #{payload}"

      @company.employee_details.create!(payload) unless @company.employee_details.where(first_name:payload[:first_name], last_name:payload[:last_name], email:payload[:email]).first.present?

      @driver.navigate.to("#{@profile}")

      sleep(2)
      doc = Nokogiri::HTML(@driver.page_source)


    end
    names
  end

  # def get_employee_data
  #   data = []
  #   i = 1
  #   loop do
  #     p "e loop - #{i}"
  #     @driver.navigate.to("https://www.linkedin.com/search/results/people/?currentCompany=%5B%2214473104%22%5D&origin=COMPANY_PAGE_CANNED_SEARCH&page=#{i}&sid=%40il")
  #     sleep(2)
  #     p "---------"
  #     p "e loop - #{i} navigate"
  #     doc = Nokogiri::HTML(@driver.page_source)
  #     p "e loop - #{i} doc"
  #     lists=doc.css("div.artdeco-card")
  #     p "e loop - #{i} list"
  #     if ((lists.css('li').first.text.split("\n")&.map(&:strip)&.select(&:presence)[0].include? "View") || (lists.css('li').first.text.split("\n")&.map(&:strip)&.select(&:presence)[0].include? "LinkedIn" ))
  #       p "e loop - #{i} before data"
  #       data = get_data_list(data,lists, i)
  #       p "e loop - #{i} after data"
  #       i = i + 1
  #     else
  #       break
  #     end
  #   end
  #   data
  # end

  # def get_data_list(data, lists, i)
  #   names = []

  #   p "e loop - #{i} inside data"
  #   lists.css('li').each do |list|

  #     p "e loop - #{i} inside data after list"
  #     @count = @count+1

  #     condition = lists.css('li').first.text.split("\n")&.map(&:strip)&.select(&:presence)[0].include? "LinkedIn"

  #     p "e loop - #{i} inside data after condition"


  #     name = list.text.split("\n")&.map(&:strip)&.select(&:presence)[0].split("View")[0]
  #     p "prev name = #{name}"


  #     p "e loop - #{i} inside data after name"
  #     names<<name unless ((name.try(:to_i).try(:to_s) == name) || (name == "LinkedIn Member"))
  #   end

  #   p "names=#{names}"

  #   names.each do |name|

  #     p "e loop - #{i} inside data after name inside name"

  #     @driver.navigate.to("https://www.linkedin.com/search/results/people/?currentCompany=%5B%2214473104%22%5D&origin=COMPANY_PAGE_CANNED_SEARCH&page=#{i}&sid=%40il")
  #     sleep(2)


  #     p "e loop - #{i} inside data after name inside name navigate"


  #     doc = Nokogiri::HTML(@driver.page_source)

  #     p "e loop - #{i} inside data after name inside name doc"

  #     email = "#{name&.split[0]&.downcase}.#{name&.split[1]&.downcase}@protonshub.in"

  #     p "e loop - #{i} inside data after name inside name before click"
  #     p "name=#{name}"

  #     @driver.find_element(:xpath, "//span[@aria-hidden='true'][contains(.,'#{name}')]")&.click
  #     sleep(2)

  #     p "e loop - #{i} inside data after name inside name after click"

  #     doc = Nokogiri::HTML(@driver.page_source)

  #     p "e loop - #{i} inside data after name inside name after doc"

  #     city = doc.css(:xpath,"//span[@class='text-body-small inline t-black--light break-words']")&.text&.strip

  #     description = doc.css(:xpath, "//div[contains(@class,'text-body-medium break-words')]")&.text&.strip

  #     designation = description

  #     image = doc.css(:xpath,"//img[contains(@width,'200')]")&.text

  #     p "e loop - #{i} inside data after name inside name before contact info"

  #     @driver.find_element(:xpath, "//a[contains(.,'Contact info')]")&.click
  #     sleep(2)

  #     p "e loop - #{i} inside data after name inside name before contact info doc"

  #     doc = Nokogiri::HTML(@driver.page_source)

  #     p "e loop - #{i} inside data after name inside name after contact info doc"

  #     mobile = doc.css(:xpath,"//span[@class='t-14 t-black t-normal']")&.text&.strip

  #     p "e loop - #{i} inside data after name inside name before payload"

  #     payload = {
  #       first_name:name,
  #       last_name:name,
  #       city: city,
  #       description: description,
  #       email:email,
  #       mobile_no:mobile,
  #       designation: designation,
  #       image: image,
  #       role_id:Role.find_by(name:'Employee').id
  #     }

  #     p "e loop - #{i} inside data after name inside name after payload"

  #     EmployeeDetail.create(payload) unless EmployeeDetail.where(first_name:payload[:first_name], last_name:payload[:last_name], email:payload[:email]).first.present?
  #     data << payload
  #   end
  #   data
  # end

end