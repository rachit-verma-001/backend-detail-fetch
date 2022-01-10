namespace :only_firefox do
  desc "TODO"
  task sync_job: :environment do
		companies = CompanyDetail.where(is_pure_apollo:true, resync_progress:"Synced")&.order(created_at: :asc)&.limit(20)
		begin
			attempts ||= 1
			options = Selenium::WebDriver::Firefox::Options.new()
			@driver = Selenium::WebDriver.for(:firefox, options: options)
			@driver.navigate.to("https://www.linkedin.com/login")
			sleep(4)
			@driver.find_element(:name, "session_key").send_keys("kushal@ausavi.com")
			sleep(4)
			puts "[INFO]: Entering password"
			@driver.find_element(:name, "session_password").send_keys("Punjab2017@")
			puts "[INFO]: Logging in"
			sleep(4)
			@driver.find_element(:xpath, "//button").click
			sleep(4)
			if companies
				companies.each do |company|

					p "Company =#{company.name}, id = #{company.id}"
					@company = company
					url = company.details&.first[9]
					p "URL =#{url}"
					if url.present?
						name = company.name
						profile = "#{url}/people"
						ProfileInformation::OnlyFirefoxFetchInfo.new.get_data(name, profile, company, @driver)
						company.update(firefox_status:"Linkedin Done")
						p "DONE"

					else
						company.update(firefox_status:"linkedin url not present")

					end
				end
			end
		rescue => e
			p "exception =#{e} for company_id =#{@company.id}"
			@driver.quit if @driver.present?
			if ((attempts += 1) <= 2)  # go back to begin block if condition ok
				puts "<retrying..>"
				puts e
				retry # ⤴
			end
		end
  end
end
