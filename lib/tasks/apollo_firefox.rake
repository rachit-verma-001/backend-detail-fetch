namespace :apollo_firefox do
  desc "TODO"
  task sync_job: :environment do
	# companies = CompanyDetail.where.not(resync_progress:"Bad Url", url_status:"started")&.where&.not(resync_progress:"Synced")&.order(created_at: :asc)&.limit(3)
	companies = CompanyDetail.where.not(resync_progress:"Bad Url", url_status:"started")&.where&.not(resync_progress:"Synced")&.order(created_at: :asc)&.limit(20)

		if companies
      options = Selenium::WebDriver::Firefox::Options.new()
      @driver = Selenium::WebDriver.for(:firefox, options: options)

      p "driver initialized"

      @driver.navigate.to("https://www.linkedin.com/login")
      sleep(4)
      # @line.update(line_number:20)
      puts "[INFO]: Entering username"
      # doc = Nokogiri::HTML(@driver.page_source).text

      @driver.find_element(:name, "session_key").send_keys("rachitverma.001@gmail.com")
      sleep(4)

      # @line.update(line_number:28)

      puts "[INFO]: Entering password"

      @driver.find_element(:name, "session_password").send_keys("gmail8871338693")

      puts "[INFO]: Logging in"

      sleep(4)

      # @line.update(line_number:36)

      @driver.find_element(:xpath, "//button").click

      sleep(4)

      p "logged in"
      companies.each do |company|

 		        unless CompanyDetail.where.not(id:company.id).where(resync_progress:"syncing in progress").present?
								attempts ||= 1
								p "company id= #{company.id}"
 		        	# if company.id <= 1675


              begin
                uri = URI.parse(company.url)
                domain = PublicSuffix.parse(uri.host)
                domain=domain.domain
              rescue => e
                company.update(reync_progress: "Bad Url")
              end
              p "domain=#{domain}"

              if domain=="linkedin.com"
                company.update(resync_progress:"Bad Url", is_linkedin_url:true )
                p "Bad URL EXCEPTION for company =#{company.name} id =#{company.id}"
                # raise Exception.new("Bad Url")
              elsif !(company.resync_progress == "Bad Url")
               begin
						      # company.update(prev_url:company.url) unless company.prev_url

                  line = company.line ? company.line : company.create_line

                  company.update(resync_progress:"syncing in progress")

                  p "company name = #{company.name}"

                  payload = ProfileInformation::AppoloFirefoxFetchInfo.new.get_data(company, line, @driver, domain)

                  @driver.quit
                  company.update(resync_progress:"Synced")

                  ExceptionDetail.first.update(ex_status:"Completed")
						      # render json: payload
						      p "Time =#{Time.now}"

                  payload
						    rescue => e
                  p "Inside Rescue resync progres == #{company.resync_progress}"
                  @driver.quit if @driver
						    	company.update(resync_progress:"Improper Synced") unless company.resync_progress=="Bad Url"
						    	company.update(resync_progress:"Bad Url") if  e.message.split(":")&.first=="bad URI(is not URI?)"
						      if ((attempts += 1) <= 3)  # go back to begin block if condition ok
						        puts "<retrying..>"
						        puts e
						        retry # ⤴
						      end
						      company
						      # render json:{success:false, error:e, line:line}
						    end

						  end


				end

			end

		end

  end
end
