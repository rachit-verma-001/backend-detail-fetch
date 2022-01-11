namespace :new_linkedin_started do
  desc "TODO"
  task sync_job: :environment do

    companies = CompanyDetail.where(no_of_employees:nil, firefox_status:"New Linkedin Started")&.order(created_at: :asc)

    begin
			attempts ||= 1
			options = Selenium::WebDriver::Firefox::Options.new()
			@driver = Selenium::WebDriver.for(:firefox, options: options)
			@driver.navigate.to("https://www.linkedin.com/login")
			sleep(4)
			@driver.find_element(:name, "session_key").send_keys("rachitverma.001@gmail.com")
			sleep(4)
			puts "[INFO]: Entering password"
			@driver.find_element(:name, "session_password").send_keys("gmail8871338693")
			puts "[INFO]: Logging in"
			sleep(4)
			@driver.find_element(:xpath, "//button").click
			sleep(10)

			if companies
				companies.each do |company|

					# p "Company =#{company.name}, id = #{company.id}"
					@company = company

					# if url.present?
						name = company.name
						profile = "#{company.url}/people"
            company.update(firefox_status:"New Linkedin Started")
						ProfileInformation::PureFirefoxFetchInfo.new.get_data(name, profile, company, @driver)
						company.update(firefox_status:"New Linkedin Done", resync_progress:"Synced")
						p "DONE"

					# else
					# 	company.update(firefox_status:"linkedin url not present")
					# end
				end
			end
		rescue => e
			p "exception =#{e} for company_id =#{@company.id}" if @company
			@driver.quit if @driver.present?
			if ((attempts += 1) <= 2)  # go back to begin block if condition ok
				puts "<retrying..>"
				puts e
				retry # ⤴
			end
		end
  end
end
