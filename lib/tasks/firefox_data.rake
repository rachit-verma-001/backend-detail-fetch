namespace :firefox_data do
  desc "TODO"
  task sync_job: :environment do
 #  	companies = CompanyDetail.where.not(resync_progress:"Synced")
 #    companies.each do |company|
	#   FirefoxWorkerJob.new.perform(company)
	# end
	# FirefoxWorkerJob.new.perform(CompanyDetail.first)

	# if CompanyDetail.first.foundation_year == "1999"
	# 	CompanyDetail.first.update(foundation_year:"2021", company_type:"Service Based")
	# else
	# 	CompanyDetail.first.update(foundation_year:"1999", company_type:"Other")
	# end


	companies = CompanyDetail.where.not(resync_progress:"Synced")&.order(created_at: :asc)&.limit(3)

		if companies
			companies.each do |company|

				begin
					attempts ||= 1
						options = Selenium::WebDriver::Firefox::Options.new(args:['-headless'])
						driver = Selenium::WebDriver.for(:firefox, options: options)
						# company = CompanyDetail.find(params[:company_id])
						ExceptionDetail.first.update(ex_status:"Running", company_detail_id:company.id)
						RakeUpdate.first.update(status:"started", company_detail_id:company.id)
						name = company.name
						profile = "#{company.url}/people"
						line = company.line ? company.line : company.create_line
						payload = ProfileInformation::FetchInfo.new.get_data(name, profile, company, driver, line)
						company.update(resync_progress:"Synced")
						driver.quit if driver
						RakeUpdate.first.update(status:"completed", company_detail_id:company.id)
						ExceptionDetail.first.update(ex_status:"Completed")
						payload
						# render json: payload
					rescue => e
						# driver.close
						driver.quit if driver
						RakeUpdate.first.update(status:"rescued", company_detail_id:company.id)

						company.update(resync_progress:"Synced")
						if ((attempts += 1) <= 2)  # go back to begin block if condition ok
							puts "<retrying..>"
							puts e
							retry # ⤴
						end
						# render json:{success:false, message:"No Such company details present, Please enter valid company details"}, status:422
						# render json:{success:false, message:"No Such company details present, Please enter valid company details"}, status:200

						# render json:{success:false, error:e, line:line}
						{success:false, error:e, line:line}
					end




			end
		end



  end
end
