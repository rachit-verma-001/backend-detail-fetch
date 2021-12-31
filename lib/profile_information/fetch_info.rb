class ProfileInformation::FetchInfo

  def get_data(name, profile, company, driver, line)
    @line = line
    @name = name
    @profile = profile
    @company  = company
    @posts = company.posts
    @driver = driver
    login
  end

  def login
    
    
    @line.update(line_number:15, completed:false)

    @driver.navigate.to("https://www.linkedin.com/login")
    sleep(7)

    @line.update(line_number:20)


    puts "[INFO]: Entering username"
    # doc = Nokogiri::HTML(@driver.page_source).text
    @driver.find_element(:name, "session_key").send_keys("kushal@ausavi.com")
    sleep(7)

    @line.update(line_number:28)

    puts "[INFO]: Entering password"
    @driver.find_element(:name, "session_password").send_keys("Punjab2017@")
    puts "[INFO]: Logging in"
    sleep(7)


    @line.update(line_number:36)

    @driver.find_element(:xpath, "//button").click
    sleep(7)
    # wait = Selenium::WebDriver::Wait.new(:timout => 10)
    # wait.until {@driver.find_element(:css, "body.ember-application")}

    @line.update(line_number:43)

    company_data
  end

  def company_data
    puts "[INFO]: Navigating to profile #{@profile}"
    sleep(7)

    @line.update(line_number:52)

    @driver.navigate.to(@profile)
    # wait = Selenium::WebDriver::Wait.new(:timout => 10)
    # wait.until {@driver.find_element(:css, "div.organization-outlet")}
    sleep(7)

    puts "[INFO]: Scraping data"

    @line.update(line_number:61)

    # sleep(4)
    doc = Nokogiri::HTML(@driver.page_source)


    @line.update(line_number:67)

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
    # no_of_employees = doc.css("span.org-top-card-secondary-content__see-all")
    # //span[@class='t-20 t-black t-bold']

    no_of_employees = doc.css("span.t-20")
    p "b employees1=#{no_of_employees}"

    no_of_employees = no_of_employees ? no_of_employees&.text&.strip : nil
    p "b employees2=#{no_of_employees}"

    logo = doc.css("div.org-top-card-primary-content__logo-container img")&.first ? doc.css("div.org-top-card-primary-content__logo-container img")&.first["src"] : nil
    p "b logo=#{logo}"

    @line.update(line_number:101)


    @driver.navigate.to("#{@company.url}/about")

    sleep(7)
    
    @line.update(line_number:108)

    doc = Nokogiri::HTML(@driver.page_source)

    sleep(7)

    @line.update(line_number:114)

    website = doc.css(:xpath,"//span[@class='link-without-visited-state']")&.text&.strip&.split("\n")&.first
    uri = URI.parse(website)
    domain = PublicSuffix.parse(uri.host)
    domain=domain.domain
    p "domain=#{domain}"
    @count = 0

    @line.update(line_number:123)

    founders = []
    # founders << get_founders('ceo')
    # founders << get_founders('coo')
    # founders <<  get_founders('cto')
    # @posts.each do |post|
    #   founders << get_founders(post,domain)
    # end


    founders << get_founders(@posts.join(","),domain)

    # employers_data= get_employee_data

        @line.update(line_number:134)

    payload = {
      name: @name,
      tagline: tagline,
      description: description_content,
      city: city,
      followers: followers,
      no_of_employees: no_of_employees,
      logo: logo,
      # founders_count: founders&.count
      # url: @profile
    }

    

    @company.update!(payload)

    @line.update(line_number:153)

    puts "[DONE]:"
    sleep(2)
    # @driver.close

    # @line.update(line_number:156)

    # @driver.quit 

    @line.update(line_number:163, completed:true )

    employees = @company.employee_details
    {
      company_detail:@company,
      founder_details: employees.where(role_id:Role.find_by(name:"Founder").id),
      employee_details: employees.where(role_id:Role.find_by(name:"Employee").id),
      line:@line
    }
  end

  def get_founders(post, domain)
    p "inside founders"
    sleep(7)
    @line.update(line_number:174)
    @driver.navigate.to("#{@profile}/?keywords=#{post}")
    sleep(7)

    @line.update(line_number:178)

    source  = @driver.page_source
    doc = Nokogiri::HTML(source)
    sleep(7)

    @line.update(line_number:184)

    names = []
    check=[]
    i = 0
    j=0

    if doc.css(:xpath,"//span[@class='t-20 t-black t-bold']").text.strip.first.to_i>=1
      loop do
        a = names
        names = doc.css("div.org-people-profile-card__profile-title")&.text.split("\n")&.reject(&:blank?)&.collect(&:strip)
        p "names = #{names}"
        if a.count == names.count
          break
        else
          i=i+1
          sleep(7)
          @line.update(line_number:201)
          @driver.execute_script("window.scrollTo(0, document.body.scrollHeight)")
              @line.update(line_number:203)

          sleep(7)
          source = @driver.page_source
          doc = Nokogiri::HTML(source)
              @line.update(line_number:208)
          sleep(7)
        end
      end
    # end

    # if doc.css(:xpath,"//span[@class='t-20 t-black t-bold']").text.strip.first.to_i>=1
    #   p "navigated founders"
    #   #
    #   doc.css('ul.display-flex').each do |founder|
    #     designation = founder.css("div.lt-line-clamp--multi-line")&.text&.strip
    #     p "designation = #{designation}"
    #     if designation.present?
    #       name=founder.css("div.org-people-profile-card__profile-title")&.text&.strip
    #       p "name=#{name}"
    #
    #       names << name
    #     end
    #   end

      p "================================="

      names&.reject(&:blank?)&.each do |name|

        p "inside name = #{name}"
        sleep(7)

        @line.update(line_number:235)

        # @driver.navigate.to("#{@profile}/?keywords=#{post}")
        @driver.navigate.to("#{@profile}/?keywords=#{name}")
        sleep(7)
        # binding.pry
    
        @line.update(line_number:241, name:name)

        @driver.find_element(:xpath,"//div[@class='org-people-profile-card__profile-title t-black lt-line-clamp lt-line-clamp--single-line ember-view'][contains(.,'#{name.split(" ")[0]}')]")&.click

        sleep(7)

        @line.update(line_number:247)
        # wait = Selenium::WebDriver::Wait.new(:timout => 10)
        # wait.until {@driver.find_element(:css, "div.text-body-medium")}

        source = @driver.page_source

        doc = Nokogiri::HTML(source)

        sleep(7)

        @line.update(line_number:257)

        city = doc.css(:xpath,"//span[@class='text-body-small inline t-black--light break-words']")&.text&.strip

        p "city = #{city}"

        description = doc.css(:xpath, "//div[@class='text-body-medium break-words']")&.text&.strip

        p "description = #{description}"

        designation = description
        p "designation = #{designation}"

        image = doc.css(:xpath,"//img[@width='200']")&.first ? doc.css(:xpath,"//img[@width='200']")&.first['src'] : nil
        p "image = #{image}"
        sleep(7)

        @line.update(line_number:275)


        @driver.find_element(:xpath, "//a[contains(.,'Contact info')]")&.click

        sleep(7)

        @line.update(line_number:282)
    
        source = @driver.page_source

        doc = Nokogiri::HTML(source)

        @line.update(line_number:288)
    
        sleep(7)

        mobile = doc.css(:xpath,"//span[@class='t-14 t-black t-normal']")&.text&.strip

        p "mobile = #{mobile}"

        # if mobile == ""
        #   response1 =   HTTParty.post("https://api.apollo.io/v1/contacts",
        #   {
        #     :body =>  {api_key: "14h23U1Vtk5VuGgDjrLopQ",first_name: name&.split()[0],last_name: name&.split()[1], title: designation, organization_name: @company.name
        #   }})
        #   mobile = response1['contact']['phone_numbers']&.join(", ") if response['contact']
        # end

        email =  doc.css(:xpath,"//a[@class='pv-contact-info__contact-link link-without-visited-state t-14']")&.text&.split[1] || "#{name&.split[0]&.downcase}.#{name&.split[1]&.downcase}@#{domain}" || nil

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
          # role_id:Role.find_by(name:'Founder').id
          role_id:Role.find_by(name:"Employee").id
        }

        p "payoad = #{payload}"

        @line.update(line_number:324)

        detail = @company.employee_details.where(first_name:payload[:first_name], last_name:payload[:last_name], email:payload[:email]).first

        unless detail.present?
          @company.employee_details.create!(payload)
        else
          detail.update(payload)
        end
        sleep(7)

        @line.update(line_number:335)

        # @driver.navigate.to("#{@profile}/?keywords=#{post}")

        sleep(7)

        # @line.update(line_number:341)

        # source = @driver.page_source
        # doc = Nokogiri::HTML(source)
        # @line.update(line_number:345)
        # sleep(7)
      end
    end
    names
  end

end