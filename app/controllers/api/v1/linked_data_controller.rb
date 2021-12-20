require "selenium-webdriver"
require "nokogiri"
require "json"
require 'csv'
require 'httparty'
class Api::V1::LinkedDataController < ApplicationController
  # before_action :authenticate_api_v1_user!
  # skip_before_action :verify_authenticity_token

  def resync
    begin
      attempts ||= 1
      options = Selenium::WebDriver::Chrome::Options.new
      options.add_argument('--ignore-cerfiticate-errors')
      options.add_argument('--disable-popup-blocking')
      options.add_argument('--disable-translate')
      # options.add_argument("--app-id = agnfnpbfkijaoceganjckcbkagmobidoi")
      options.add_extension("/home/rachit/Things/WebScrapping/mlhacebjlefifkldmkbilohcaiednbik-3.0.6-Crx4Chrome.com.crx")
      driver = Selenium::WebDriver.for :chrome, options: options
      company = CompanyDetail.find(params[:company_id])
      name = company.name
      # company.destroy! if company.present?
      profile = company.url+"/people"
      # company = CompanyDetail.find_or_create_by(name:name)
      payload = ProfileInformation::FetchInfo.new.get_data(name, profile, company, driver)
      render json: payload
      # render json:{success:true}
    rescue => e
      driver.quit
      if ((attempts += 1) <= 4)  # go back to begin block if condition ok
        puts "<retrying..>"
        puts e
        retry # ⤴
      end
      # render json:{success:false, message:"No Such company details present, Please enter valid company details"}, status:422
      render json:{success:false, message:"No Such company details present, Please enter valid company details"}, status:200
    end
  end

  def export_csv
    # cname = params[:company_name]
    # url = params[:url]+"/people" if params[:url].present?
    # company = CompanyDetail.find_by(name:cname,url:url)
    company = CompanyDetail.find(params[:company_id])

    if company
      employees = company.employee_details
      temp_csv = CSV.generate(encoding: 'UTF-8') do |csv|
        csv << %w[first_name last_name city designation email image mobile_no]
        employees.each do |employee|
          csv << [employee.first_name, employee.last_name, employee.city, employee.designation, employee.email, employee.image, employee.mobile_no]
        end
      end

      send_data(temp_csv, :type => 'test/csv', :filename => 'detail.csv')
    else
      render json:{success:false, message:"No Such company details present"}
    end
  end

  def search
    #name, city, designation

    # company = CompanyDetail.find_by('lower(name) like ?', "#{params[:company_name].downcase}%")
    company = CompanyDetail.find(params[:id])
    ppage = params[:page].to_i>0 ? params[:page] : CompanyDetail::PAGE
    pppage = params[:per_page].to_i>0 ? params[:per_page] : CompanyDetail::PER_PAGE

    if company.present?
      employee_details = company.employees_data
      founder_details = company.founders_data

      # employee_details = EmployeeDetail.where(role:Role.find_by(name:"Employee"))
      # founder_details = EmployeeDetail.where(role:Role.find_by(name:"Founder"))

      # employee_details = employee_details.where('lower(city) like ?', "%#{params[:city]&.downcase}, #{params[:state]&.downcase}, #{params[:country]&.downcase}%") if (params[:city].present? || params[:state].present? || params[:country].present?)

      employee_details = employee_details.where('lower(city) like ?', "%#{params[:country]&.downcase}%") if ((params[:country].present?) && !(params[:country]=="null"))

      employee_details = employee_details.where('lower(city) like ?', "%#{params[:state].downcase}%") if params[:state].present? && !(params[:state]=="null")

      employee_details = employee_details.where('lower(city) like ?', "#{params[:city].downcase}%") if params[:city].present? && !(params[:city]=="null")

      # employee_details = employee_details.where('lower(designation) like ?',"#{params[:designation].downcase}%") if params[:designation].present?

      employee_details = employee_details.where('lower(first_name) like ?',"#{params[:first_name].downcase}%") if params[:first_name].present?

      employee_details = employee_details.where('lower(last_name) like ?', "#{params[:last_name].downcase}%") if params[:last_name].present?

      employee_details = employee_details.where("lower(email) like ?", "#{params[:email].downcase}%") if params[:email].present?


      founder_details = founder_details.where('lower(city) like ?', "#{params[:city]&.downcase}, #{params[:state]&.downcase}, #{params[:country]&.downcase}%") if ( (params[:city].present? && !(params[:city]=="null")) || (params[:state].present? && !(params[:state]=="null")) || (params[:country].present? && !(params[:country]=="null")))

      # founder_details = founder_details.where('lower(city) like ?', "%#{params[:state].downcase}%") if params[:state].present?

      # founder_details = founder_details.where('lower(city) like ?', "#{params[:country].downcase}%") if params[:country].present?

      # founder_details = founder_details.where('lower(designation) like ?',"#{params[:designation].downcase}%") if params[:designation].present?

      founder_details = founder_details.where('lower(first_name) like ?',"#{params[:first_name].downcase}%") if params[:first_name].present?
      founder_details = founder_details.where('lower(last_name) like ?', "#{params[:last_name].downcase}%") if params[:last_name].present?
      founder_details = founder_details.where("lower(email) like ?", "#{params[:email].downcase}%") if params[:email].present?

      ftypes = []
      etypes = []

      if (params[:employee_types].present? && !(params[:employee_types]=="null") && !(params[:employee_types]==["undefined"]))

        employee_types = params[:employee_types]

         employee_types = params[:employee_types].split(",") if (params[:isCsv]=="true")

          employee_types.each do |employee_type|

          if employee_type == "Employees"
            etypes = etypes + employee_details
          elsif employee_type == "Chief Executive Officer"

            # ftypes = ftypes + founder_details.where('lower(designation) like ?', "%#{employee_type&.downcase}%")
            etypes = etypes + employee_details.where('lower(designation) like ? OR lower(designation) like ?', "%#{employee_type&.downcase}%", "%ceo%")

          elsif employee_type == "Chief Technology Officer"
            # ftypes = ftypes + founder_details.where('lower(designation) like ?', "%#{employee_type&.downcase}%")
            etypes = etypes + employee_details.where('lower(designation) like ? OR lower(designation) like ?', "%#{employee_type&.downcase}%", "%cto%")

          elsif employee_type == "Chief Operating Officer"
            # ftypes = ftypes + founder_details.where('lower(designation) like ?', "%#{employee_type&.downcase}%")
            etypes = etypes + employee_details.where('lower(designation) like ? OR lower(designation) like ?', "%#{employee_type&.downcase}%", "%coo%")

          elsif employee_type == "Human Resource"


            # ftypes = ftypes + founder_details.where('lower(designation) like ?', "%#{employee_type&.downcase}%")
            etypes = etypes + employee_details.where('lower(designation) like ?', "%#{employee_type&.downcase}%")

          elsif employee_type == "Founder"
            # ftypes = ftypes + founder_details.where('lower(designation) like ?', "%#{employee_type&.downcase}%")
            etypes = etypes + employee_details.where('lower(designation) like ? OR lower(designation) like ?', "%#{employee_type&.downcase}%", "%co-founder%")

          else
            # ftypes = ftypes + founder_details.where('lower(designation) like ?', "%#{employee_type&.downcase}%")
            etypes = etypes + employee_details.where('lower(designation) like ?', "%#{employee_type&.downcase}%")

          end

        end
      end

      next_page =  employee_details.count>(pppage.to_i*ppage.to_i) ? ppage.to_i+1 : nil

      total_pages = (employee_details.count/pppage.to_f).round

      total_count = employee_details.count
      if ftypes.present?
        founder_details = ftypes.count > (pppage.to_i*ppage.to_i) ? ftypes.drop(pppage.to_i*ppage.to_i).first(pppage.to_i) : ftypes
      end



      if (params[:employee_types].present? && !(params[:employee_types]=="null") && !(params[:employee_types]==["undefined"]))

        employee_details = etypes&.count > (pppage.to_i*ppage.to_i) ? etypes&.drop(pppage.to_i*ppage.to_i)&.first(pppage.to_i) : etypes unless params[:isCsv]=="true"
        employee_details = etypes if params[:isCsv]=="true"


        next_page =  etypes&.count>(pppage.to_i*ppage.to_i) ? ppage.to_i+1 : nil
        total_pages = (etypes&.count/pppage.to_f).round
        total_count = etypes&.count
      else
        employee_details = employee_details.paginate(page:ppage,per_page:pppage) unless params[:isCsv]=="true"
        employee_details = employee_details if params[:isCsv]=="true"
      end

      total_pages = total_pages > 0 ? total_pages : 0

      unless params[:isCsv]=="true"
        render json:{
          company_detail:company,
          founder_details: founder_details,
          employee_details: employee_details,
          pagination: {
            current_page: ppage,
            next_page: next_page,
            # prev_page: employee_details.prev_page,
            total_pages: total_pages,
            total_count: total_count
            #total_count: products.total_count
          },
          company: company,
          founders_details:founder_details,
          success:true
        }
      else
        temp_csv = CSV.generate(encoding: 'UTF-8') do |csv|
          csv << %w[first_name last_name city designation email image mobile_no]
          employee_details.each do |employee|
            csv << [employee.first_name, employee.last_name, employee.city, employee.designation, employee.email, employee.image, employee.mobile_no]
          end
        end
        send_data(temp_csv, :type => 'test/csv', :filename => 'detail.csv')
      end
    else
      render json:{success:false, message:"No Such company details present, Please enter valid company details"}, status:422
    end
  end

  def company_info
    begin
      url = params[:url]+"/people"
      # company = CompanyDetail.find_by(name:params[:company_name], url:url)
      #
      company = CompanyDetail.find_by(name:params[:company_name].strip)
      if company
        employees = company.employee_details
        render json:{
          company_detail:company,
          founder_details: employees.where(role_id:Role.find_by(name:"Founder").id),
          employee_details: employees.where(role_id:Role.find_by(name:"Employee").id)
        }
      else
        render json:{success:false, message:"No Such company details present"}
      end
    rescue => e
      render json: {error:e}, status: 422
    end
  end

  def sales_qi_linkedin
    begin
      payload = SalesQiProfileInformation::FetchInfo.new.get_data
      render json: payload, status: :ok
    rescue => e
      render json: {error:e}, status: 422
    end
  end


  private
  def render_response
    render json:{
      company_detail:CompanyDetail.all,
      founder_details: EmployeeDetail.where(role_id:Role.find_by(name:"Founder").id),
      employee_details: EmployeeDetail.where.not(role_id:Role.find_by(name:"Founder").id)
    }
  end

end
