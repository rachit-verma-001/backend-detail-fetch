class ProfileInformation::OnlyFirefoxFetchInfo

  def get_data(name, profile, company, driver)

    @name = name
    @profile = profile
    @company  = company
    @posts = company.posts
    @driver = driver
    login
  end

  def login
    company_data
  end

  def company_data
    puts "[INFO]: Navigating to profile #{@profile}"
    @driver.navigate.to(@profile)
    sleep(4)
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
    no_of_employees = doc.css("span.t-20")
    p "b employees1=#{no_of_employees}"
    no_of_employees = no_of_employees ? no_of_employees&.text&.strip : nil
    p "b employees2=#{no_of_employees}"
    logo = doc.css("div.org-top-card-primary-content__logo-container img")&.first ? doc.css("div.org-top-card-primary-content__logo-container img")&.first["src"] : nil
    p "b logo=#{logo}"


    @count = 0
    payload = {
      name: @name,
      tagline: tagline,
      description: description_content,
      city: city,
      followers: followers,
      no_of_employees: no_of_employees,
      logo: logo,
    }
    p "payload=#{payload}"
    @company.update!(payload)
    p "Company Updated"
    employee_update
    puts "[DONE]:"
  end

  def employee_update
    p "Inside EMployees"

    link_profiles = @company.details&.map{|d|[d[1],d[0]]}

    p "Link Profile = #{link_profiles}"

    link_profiles&.uniq&.each do |profile|
      first_name= profile[1]&.split()[0]
      last_name= profile[1]&.split()[1]
      p "Name = #{profile[1]}"
      employee = @company.employee_details&.where(first_name:first_name, last_name:last_name)&.first

      p "Employee=#{employee.first_name}"

      if employee.present?
        @driver.navigate.to(profile[0])
        sleep(4)
        source = @driver.page_source
        doc = Nokogiri::HTML(source)
        mobile = doc.css(:xpath,"//span[@class='t-14 t-black t-normal']")&.text&.strip
        p "mobile = #{mobile}"
        email =  doc.css(:xpath,"//a[@class='pv-contact-info__contact-link link-without-visited-state t-14']")&.text&.split[1] || "#{first_name&.downcase}.#{last_name&.downcase}@#{@domain}" || nil
        p "email=#{email}"
        employee.update(email:email, mobile_no:mobile)
        p "Employee Updated"
      end

    end


  end

end