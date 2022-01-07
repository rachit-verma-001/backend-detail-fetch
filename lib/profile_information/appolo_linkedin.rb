class ProfileInformation::AppoloLinkedin

  def get_data(company, line, driver)
    @line = line
    @driver = driver
    @company  = company
    @posts = company.posts
    company_data
  end

  def company_data
    uri = URI.parse(@company.url)
    domain = PublicSuffix.parse(uri.host)
    domain=domain.domain
    p "domain=#{domain}"

    data = {
      api_key: "14h23U1Vtk5VuGgDjrLopQ",
      q_organization_domains: @company.url,
      page: 1,
      person_titles: @company.posts
    }

    p "getting appollo info"
    uri = URI.parse("https://api.apollo.io/v1/mixed_people/search")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
    request.body = data.to_json
    response = http.request(request)
    result = JSON.parse(response.body)
    if domain=="linkedin.com"
      @company.update(resync_progress:"Bad Url")
      raise Exception.new("Bad Url")
    end
    names = []
    @driver.navigate.to("https://www.linkedin.com/login")
    sleep(4)
    @line.update(line_number:20)
    puts "[INFO]: Entering username"
    # doc = Nokogiri::HTML(@driver.page_source).text
    @driver.find_element(:name, "session_key").send_keys("kushal@ausavi.com")
    sleep(4)
    @line.update(line_number:28)
    puts "[INFO]: Entering password"
    @driver.find_element(:name, "session_password").send_keys("Punjab2017@")
    puts "[INFO]: Logging in"
    sleep(4)
    @line.update(line_number:36)
    @driver.find_element(:xpath, "//button").click
    sleep(4)
    names << result["people"]&.map{|a|[a["name"], a["linkedin_url"], a["title"], a["photo_url"], a["email"], a["city"], a["state"], a["country"], a["phone_numbers"]]}
    p "people apollo names = #{names}"
    names << result["contacts"]&.map{|a|[a["name"], a["linkedin_url"], a["title"], a["photo_url"],a["email"], a["city"], a["state"], a["country"], a["phone_numbers"]]}
    names&.flatten(1)&.uniq&.reject(&:blank?)&.each do |people|
      name = people[0]
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
      # mobile = people[8]&.join(",")
      # email = people[4]
      # email = "#{name&.split[0]&.downcase}.#{name&.split[1]&.downcase}@#{domain}" if (email == "email_not_unlocked@domain.com" || email.blank?)
      email =  doc.css(:xpath,"//a[@class='pv-contact-info__contact-link link-without-visited-state t-14']")&.text&.split[1] || "#{name&.split[0]&.downcase}.#{name&.split[1]&.downcase}@#{domain}" || nil
      p "email=#{email}"
      @driver.quit
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

    end
    employees = @company.employee_details
    # update_company_data
    {
      company_detail:@company,
      founder_details: employees.where(role_id:Role.find_by(name:"Founder").id),
      employee_details: employees.where(role_id:Role.find_by(name:"Employee").id),
      line:@line,
      success:true
    }
  end

end