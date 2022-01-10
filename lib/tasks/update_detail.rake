namespace :update_detail do
  desc "TODO"
  task self_updte: :environment do
  	begin
			attempts ||= 1
			options = Selenium::WebDriver::Firefox::Options.new(args:['-headless'])
  		options.add_argument('--window-size=1920,1080')
			@driver = Selenium::WebDriver.for(:firefox, options: options)
  		companies =  CompanyDetail.where(resync_progress:"Not Synced")&.where(url_status:nil)&.order(created_at: :asc)
  		p "companies count=#{companies.count}"
	    @driver.navigate.to("https://www.linkedin.com/login")
	    sleep(4)
	    puts "[INFO]: Entering username"
	    @driver.find_element(:name, "session_key").send_keys("kushal@ausavi.com")
	    sleep(4)

	    puts "[INFO]: Entering password"
	    @driver.find_element(:name, "session_password").send_keys("Punjab2017@")
	    puts "[INFO]: Logging in"
	    sleep(4)

	    @driver.find_element(:xpath, "//button").click
	    sleep(4)
	    companies.each do |company|
	    	p "id=#{company.id}, unless=2930"
	    	if company.id<=2930

		    	p "company =#{company.name}"
		      @driver.navigate.to("#{company.url}/about")
			    sleep(4)
		      company.update(url_status:"started")
		      p "prev url =#{company.url}" 
		      company.update(prev_url:company.url) unless company.prev_url
			    p "about page"
			    doc = Nokogiri::HTML(@driver.page_source)
			    website = doc.css(:xpath,"//span[@class='link-without-visited-state']")&.text&.strip&.split("\n")&.first
			    p "website = #{website}"

			    company.update(url:website, url_status:"updated")
			    p "company website = #{company.url}, company name =#{company.name}, url status = #{company.url_status}, prev_url =#{company.prev_url}"
			  end


		  end

		rescue => e
				# driver.close
				@driver.quit if @driver
				# RakeUpdate.first.update(status:"rescued", company_detail_id:company.id)
				p "exception =#{e}"
				p "============"
				p "Attempts= #{attempts}"
				# company.update(resync_progress:"Not Synced")
				if ((attempts += 1) <= 2)  # go back to begin block if condition ok
					puts "<retrying..>"
					puts e
					retry # ⤴
				end
				# render json:{success:false, message:"No Such company details present, Please enter valid company details"}, status:422
				# render json:{success:false, message:"No Such company details present, Please enter valid company details"}, status:200

				# render json:{success:false, error:e, line:line}
				# {success:false, error:e, line:line}
		end


	end
end






















# 	# companies =  CompanyDetail.where(no_of_employees:nil)&.limit(2)
# 	companies =  CompanyDetail.where(resync_progress:"Not Synced")&.limit(20)

# 		if companies
# 			companies.each do |company|

# 				begin
# 					attempts ||= 1
# 						options = Selenium::WebDriver::Firefox::Options.new(args:['-headless'])
# 						driver = Selenium::WebDriver.for(:firefox, options: options)
# 						# company = CompanyDetail.find(params[:company_id])
# 						ExceptionDetail.first.update(ex_status:"Running", company_detail_id:company.id)
# 						RakeUpdate.first.update(status:"started", company_detail_id:company.id)
# 						name = company.name
# 						profile = "#{company.url}/people"
# 						line = company.line ? company.line : company.create_line
# 						payload = ProfileInformation::FetchInfo.new.get_data(name, profile, company, driver, line)
# 						company.update(resync_progress:"Synced")
# 						driver.quit if driver
# 						RakeUpdate.first.update(status:"completed", company_detail_id:company.id)
# 						ExceptionDetail.first.update(ex_status:"Completed")
# 						payload
# 						# render json: payload
# 					rescue => e
# 						# driver.close
# 						driver.quit if driver
# 						RakeUpdate.first.update(status:"rescued", company_detail_id:company.id)

# 						company.update(resync_progress:"Synced")
# 						if ((attempts += 1) <= 2)  # go back to begin block if condition ok
# 							puts "<retrying..>"
# 							puts e
# 							retry # ⤴
# 						end
# 						# render json:{success:false, message:"No Such company details present, Please enter valid company details"}, status:422
# 						# render json:{success:false, message:"No Such company details present, Please enter valid company details"}, status:200

# 						# render json:{success:false, error:e, line:line}
# 						{success:false, error:e, line:line}
# 					end




# 			end
# 		end



#   end

# end





# 2755




