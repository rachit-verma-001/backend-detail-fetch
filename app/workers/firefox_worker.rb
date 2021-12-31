# frozen_string_literal: true

class FirefoxWorker
	include Sidekiq::Worker
	def perform(company)
		begin
      options = Selenium::WebDriver::Firefox::Options.new(args:['-headless'])
      driver = Selenium::WebDriver.for(:firefox, options: options)
      # company = CompanyDetail.find(params[:company_id])
      ExceptionDetail.first.update(ex_status:"Running", company_detail_id:company.id)
      name = company.name
      profile = company.url+"/people"
      line = company.line ? company.line : company.create_line
      payload = ProfileInformation::FetchInfo.new.get_data(name, profile, company, driver, line)
      driver.quit if driver
      payload
      # render json: payload
    rescue => e
      # driver.close 
      driver.quit if driver

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