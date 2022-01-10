class ProfileInformation::AppoloFirefoxFetchInfo

  def get_data(company, line, driver, domain)
    @line = line
    @domain = domain
    @driver = driver
    @company  = company
    @posts = company.posts
    fetchData
  end

  def fetchData
    #tushar sir api
    data = {
      # api_key: "14h23U1Vtk5VuGgDjrLopQ",
      api_key: "ukm4wa8H1PeV_yJOvnHPDw",
      q_organization_domains: @company.url,
      page: 1,
      person_titles: @company.posts
    }
    # binding.pry
    unless @company.details.present?

      p "getting appollo info"
      uri = URI.parse("https://api.apollo.io/v1/mixed_people/search")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
      request.body = data.to_json
      response = http.request(request)
      result = JSON.parse(response.body)
      names = []
      names << result["people"]&.map{|a|[a["name"], a["linkedin_url"], a["title"], a["photo_url"], a["email"], a["city"], a["state"], a["country"], a["phone_numbers"]]}
      p "people apollo names = #{names}"
      names << result["contacts"]&.map{|a|[a["name"], a["linkedin_url"], a["title"], a["photo_url"],a["email"], a["city"], a["state"], a["country"], a["phone_numbers"]]}

      @company.update(details:names&.flatten(1)&.uniq&.reject(&:blank?))

    end


    names = @company.details
    p "names=#{names}"
    names&.uniq&.reject(&:blank?)&.each do |people|
      name = people[0]
      nam = @company.employee_details&.map{|a|["#{a&.first_name} #{a&.last_name}"]}
      unless nam&.flatten&.include? name
        attempts ||= 1
        p "Navigate to #{people[1]}"
        @driver.navigate.to(people[1])
        sleep(4)
        source = @driver.page_source
        doc = Nokogiri::HTML(source)
        city = doc.css(:xpath,"//span[@class='text-body-small inline t-black--light break-words']")&.text&.strip
        city = "#{people[5]}, #{people[6]}, #{people[7]}" unless city
        p "city =#{city}"
        @driver.find_element(:xpath, "//a[contains(.,'Contact info')]")&.click
        sleep(4)
        source = @driver.page_source
        doc = Nokogiri::HTML(source)
        mobile = doc.css(:xpath,"//span[@class='t-14 t-black t-normal']")&.text&.strip
        p "mobile = #{mobile}"
        email =  doc.css(:xpath,"//a[@class='pv-contact-info__contact-link link-without-visited-state t-14']")&.text&.split[1] || "#{name&.split[0]&.downcase}.#{name&.split[1]&.downcase}@#{@domain}" || nil
        p "email=#{email}"

        designation = people[2]
        image = people[3]
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
          role_id:Role.find_by(name:"Employee").id,
          # linedin_url: people[1]
        }
        p "payoad = #{payload}"
        @line.update(line_number:324)
        detail = @company.employee_details.where(first_name:payload[:first_name], last_name:payload[:last_name], email:payload[:email]).first
        unless detail.present?
          @company.employee_details.create!(payload)
        else
          detail.update(payload)
        end
      end
    end
    employees = @company.employee_details
    # company_data
    {
      company_detail:@company,
      founder_details: employees.where(role_id:Role.find_by(name:"Founder").id),
      employee_details: employees.where(role_id:Role.find_by(name:"Employee").id),
      line:@line,
      success:true
    }
  end


  def company_data
    @driver.navigate.to(@profile)
    # wait = Selenium::WebDriver::Wait.new(:timout => 10)
    # wait.until {@driver.find_element(:css, "div.organization-outlet")}
    sleep(4)
    puts "[INFO]: Scraping data"
    @line.update(line_number:61)
    # sleep(4)
    doc = Nokogiri::HTML(@driver.page_source)
    # @line.update(line_number:67)
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

    # @line.update(line_number:101)

  end

end