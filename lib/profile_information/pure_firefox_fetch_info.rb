class ProfileInformation::PureFirefoxFetchInfo

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

    founders = []

    @driver.navigate.to("#{@company.url}/about")
    sleep(4)
    doc = Nokogiri::HTML(@driver.page_source)
    website = doc.css(:xpath,"//span[@class='link-without-visited-state']")&.text&.strip&.split("\n")&.first
    uri = URI.parse(website)
    domain = PublicSuffix.parse(uri.host)
    domain=domain.domain
    p "domain=#{domain}"

    about = doc.css(:xpath,"//p[@class='break-words white-space-pre-wrap mb5 text-body-small t-black--light']")&.text

    payload = {
      name: @name,
      tagline: tagline,
      description: description_content,
      city: city,
      followers: followers,
      no_of_employees: no_of_employees,
      logo: logo,
      about: about
    }

    p "payload=#{payload}"


    @posts.each do |post|
      p "inside First Post = #{post}"
      unless @company.done_posts.include? post.downcase
        p "Post Not Done = #{post}"
        founders << employee_update(post,domain)
      end
    end

    p "employee Updated"
    @company.update!(payload)
    p "Company Updated"
    puts "[DONE]:"
  end

  def employee_update(post, domain)
    p "Inside EMployees"


    p "POST= #{post}"
    @driver.navigate.to("#{@profile}/?keywords=#{post}")
    sleep(4)

    source  = @driver.page_source
    doc = Nokogiri::HTML(source)
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

          @driver.execute_script("window.scrollTo(0, document.body.scrollHeight)")

          sleep(5)
          source = @driver.page_source
          doc = Nokogiri::HTML(source)

        end
      end

      names&.reject(&:blank?)&.each do |name|
        p "inside name = #{name}"
        sleep(4)



        unless @company.employee_details&.pluck(:first_name, :last_name).map{|a|["#{a[0]} #{a[1]}"] }&.flatten&.include? name

          p "Inside Unless name = #{name}"

          @driver.navigate.to("#{@profile}/?keywords=#{name}")
          sleep(4)
          @driver.find_element(:xpath,"//div[@class='org-people-profile-card__profile-title t-black lt-line-clamp lt-line-clamp--single-line ember-view'][contains(.,'#{name.split(" ")[0]}')]")&.click
          sleep(4)
          source = @driver.page_source
          doc = Nokogiri::HTML(source)
          city = doc.css(:xpath,"//span[@class='text-body-small inline t-black--light break-words']")&.text&.strip
          p "city = #{city}"
          description = doc.css(:xpath, "//div[@class='text-body-medium break-words']")&.text&.strip
          p "description = #{description}"
          designation = description
          p "designation = #{designation}"
          image = doc.css(:xpath,"//img[@width='200']")&.first ? doc.css(:xpath,"//img[@width='200']")&.first['src'] : nil
          p "image = #{image}"
          @driver.find_element(:xpath, "//a[contains(.,'Contact info')]")&.click
          sleep(4)
          source = @driver.page_source

          doc = Nokogiri::HTML(source)

          mobile = doc.css(:xpath,"//span[@class='t-14 t-black t-normal']")&.text&.strip

          p "mobile = #{mobile}"


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
          detail = @company.employee_details.where(first_name:payload[:first_name], last_name:payload[:last_name], email:payload[:email]).first

          unless detail.present?
            @company.employee_details.create!(payload)
          else
            detail.update(payload)
          end
        end
      end
    end
    @company.done_posts << post
    @company.save
    names
  end

end






      # doc.css(:xpath, "//div[@class='org-people-profile-card__profile-title t-black lt-line-clamp lt-line-clamp--single-line ember-view']")&.each do |t_loop|


      # @driver.navigate.to("#{@profile}/?keywords=#{post}")
      # sleep(4)

      # source  = @driver.page_source
      # doc = Nokogiri::HTML(source)
      # n_count = 0


      #     p "Inside Loop i=#{i}, n_count=#{n_count}"

      #     t_name = t_loop&.text&.strip

      #     p "tname = #{t_name}"

      #     # @driver.navigate.to("#{@profile}/?keywords=#{post}")
      #     # sleep(4)

      #     # source  = @driver.page_source
      #     # doc = Nokogiri::HTML(source)
      #     # n_count = 0


        # loop do
        # end #Remove
        # @driver.navigate.to("#{@profile}/?keywords=#{post}")
      # end #Remove










      # if names.include? t_loop&.text&.strip

      #   unless @company.employee_details&.pluck(:first_name, :last_name).map{|a|["#{a[0]} #{a[1]}"] }&.flatten&.include? t_name



      #     p "Inside Unless Fetching Profiles...."

      #     # @driver.navigate.to("#{@profile}/?keywords=#{name}")
      #     @driver.navigate.to("#{@profile}/?keywords=#{post}")

      #     sleep(4)


      #     # doc.css(:xpath, "//div[@class='org-people-profile-card__profile-title t-black lt-line-clamp lt-line-clamp--single-line ember-view']").each do |it_loop|


      #       p "Inside IT LOOP "
      #       # if it_loop&.text&.strip ==  name

      #         p "INSIDE LOOP NAME = #{t_name}"
      #         @driver.find_element(:xpath,"//div[@class='org-people-profile-card__profile-title t-black lt-line-clamp lt-line-clamp--single-line ember-view'][contains(.,'#{t_name.split(" ")[0]}')]")&.click
      #         sleep(4)
      #         name = t_name
      #         source = @driver.page_source
      #         doc = Nokogiri::HTML(source)
      #         city = doc.css(:xpath,"//span[@class='text-body-small inline t-black--light break-words']")&.text&.strip
      #         p "city = #{city}"
      #         description = doc.css(:xpath, "//div[@class='text-body-medium break-words']")&.text&.strip
      #         p "description = #{description}"
      #         designation = description
      #         p "designation = #{designation}"
      #         image = doc.css(:xpath,"//img[@width='200']")&.first ? doc.css(:xpath,"//img[@width='200']")&.first['src'] : nil
      #         p "image = #{image}"
      #         p "Fetching Contact Info....."
      #         @driver.find_element(:xpath, "//a[contains(.,'Contact info')]")&.click
      #         sleep(4)
      #         source = @driver.page_source
      #         doc = Nokogiri::HTML(source)
      #         mobile = doc.css(:xpath,"//span[@class='t-14 t-black t-normal']")&.text&.strip
      #         p "mobile = #{mobile}"
      #         email =  doc.css(:xpath,"//a[@class='pv-contact-info__contact-link link-without-visited-state t-14']")&.text&.split[1] || "#{name&.split[0]&.downcase}.#{name&.split[1]&.downcase}@#{domain}" || nil

      #         p "email=#{email}"

      #         payload = {
      #           first_name: name&.split()[0],
      #           last_name: name&.split()[1],
      #           city: city,
      #           # description: description,
      #           email:email,
      #           mobile_no:mobile,
      #           designation: designation,
      #           image: image,
      #           # role_id:Role.find_by(name:'Founder').id
      #           role_id:Role.find_by(name:"Employee").id
      #         }
      #         p "payoad = #{payload}"
      #         detail = @company.employee_details.where(first_name:payload[:first_name], last_name:payload[:last_name], email:payload[:email]).first

      #         unless detail.present?
      #           @company.employee_details.create!(payload)
      #         else
      #           detail.update(payload)
      #         end
      #       # end #Remove This

      #     # end #Remove This

      #   end
      # else

      #   p "Inside Else n_count=#{n_count}, i=#{i}"
      #   binding.pry

      #     break if ncount == i
      #     n_count = n_count+1
      #     @driver.execute_script("window.scrollTo(0, document.body.scrollHeight)")
      #     sleep(5)
      #     source = @driver.page_source
      #     doc = Nokogiri::HTML(source)
      # end
