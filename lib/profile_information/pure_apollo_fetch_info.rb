class ProfileInformation::PureApolloFetchInfo

  def get_data(company, line, domain)
    @line = line
    @company  = company
    @posts = company.posts
    @domain = domain
    company_data
  end

  def company_data

    data = {
      # api_key: "14h23U1Vtk5VuGgDjrLopQ",
      api_key: "ukm4wa8H1PeV_yJOvnHPDw",
      q_organization_domains: @company.url,
      page: 1,
      person_titles: @company.posts
    }

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
      city = "#{people[5]}, #{people[6]}, #{people[7]}"
      mobile = people[8]&.join(",")


      email = people[4]
      email = "#{name&.split[0]&.downcase}.#{name&.split[1]&.downcase}@#{@domain}" if (email == "email_not_unlocked@domain.com" || email.blank?)

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
        linedin_url:people[1]
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
    {
      company_detail:@company,
      founder_details: employees.where(role_id:Role.find_by(name:"Founder").id),
      employee_details: employees.where(role_id:Role.find_by(name:"Employee").id),
      line:@line,
      success:true
    }
  end
end