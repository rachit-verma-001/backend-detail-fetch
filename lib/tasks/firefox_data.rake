namespace :firefox_data do
  desc "TODO"
  task sync_job: :environment do
	companies = CompanyDetail.where.not(resync_progress:"Bad Url", url_status:"started")&.where&.not(resync_progress:"Synced")&.order(created_at: :asc)&.limit(3)

	# if companies
	# 	companies.each do |company|		
	# 		unless company.id == 276
	# 		  company.update(prev_url:company.url) unless company.prev_url
 #   			 attempts ||= 1
			  
	# 		  begin
	# 	      options = Selenium::WebDriver::Firefox::Options.new(args:['-headless'])
	# 	      driver = Selenium::WebDriver.for(:firefox, options: options)
	# 	      options.add_argument('--window-size=1920,1080')
 #      		options.add_argument('--disable-dev-shm-usage')
		      
	# 	      # 
	# 	      # company = CompanyDetail.find(params[:company_id])
	# 	      company.update(prev_url:company.url) unless company.prev_url
	# 	      line = company.line ? company.line : company.create_line
	# 	      payload = ProfileInformation::AppoloLinkedin.new.get_data(company, line, driver)
	# 	      company.update(resync_progress:"Synced")
	# 	      ExceptionDetail.first.update(ex_status:"Completed")
	# 			rescue => e
	# 	    	company.update(resync_progress:"Improper Synced") unless company.resync_progress=="Bad Url"
	# 	      if ((attempts += 1) <= 2)  # go back to begin block if condition ok
	# 	        puts "<retrying..>"
	# 	        puts e
	# 	        retry # ⤴
	# 	      end
	# 	      company
	# 	      # render json:{success:false, error:e, line:line}
	# 	    end
	# 		end
	# 	end
	# end



		if companies
			companies.each do |company|
 		        
 		        unless CompanyDetail.where.not(id:company.id).where(resync_progress:"syncing in progress").present?
											attempts ||= 1
								p "company id= #{company.id}"
 		        	if company.id <= 1675
						    begin
						      company.update(prev_url:company.url) unless company.prev_url
						      line = company.line ? company.line : company.create_line
						      company.update(resync_progress:"syncing in progress")
						      p "company name = #{company.name}"
						      payload = ProfileInformation::AppoloFetchInfo.new.get_data(company, line)
						      company.update(resync_progress:"Synced")
						      ExceptionDetail.first.update(ex_status:"Completed")
						      # render json: payload
						      p "Time =#{Time.now}"
						      payload
						    rescue => e
						    	p "Inside Rescue resync progres == #{company.resync_progress}"
						    	
						    	company.update(resync_progress:"Improper Synced") unless company.resync_progress=="Bad Url"						      
						    	company.update(resync_progress:"Bad Url") if  e.message.split(":")&.first=="bad URI(is not URI?)"
						      if ((attempts += 1) <= 2)  # go back to begin block if condition ok
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
