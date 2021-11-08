require "selenium-webdriver"
require "nokogiri"
require "json"
require 'csv'

class Api::V1::LinkedDataController < ApplicationController
  before_action :authenticate_api_v1_user!
  # skip_before_action :verify_authenticity_token

  def resync
    begin
      name = params[:company_name]
      profile = params[:url]+"/people"
      company = CompanyDetail.find_or_create_by(name:name)
      payload = ProfileInformation::FetchInfo.new.get_data(name, profile, company)
      render json: payload
    rescue => e
      render json: {error:e}
    end
  end

  def export_csv
    name = params[:company_name]
    url = params[:url]
    company = CompanyDetail.find_by(name:name,url:url)
    if company
      employees = company.employee_details
      temp_csv = CSV.generate(encoding: 'UTF-8') do |csv|
        csv << %w[first_name last_name city designation email image description]
        employees.each do |employee|
          csv << [employee.first_name, employee.last_name, employee.city, employee.designation, employee.email]
        end
      end

      respond_to do |format|
        format.csv { send_data temp_csv }
      end
      # send_data(temp_csv, :type => 'test/csv', :filename => 'detail.csv')
    else
      render json:{success:false, message:"No Such company details present"}
    end
  end


  def search
    #name, city, designation
    company = CompanyDetail.find_by(name:params[:company_name])

    if company.present?
      employee_details = company.employees_data
      founder_details = company.founders_data
      employee_details = employee_details.where(city:params[:city]) if params[:city].present?
      employee_details = employee_details.where(designation:params[:designation]) if params[:designation].present?
      employee_details = employee_details.where(first_name:params[:first_name]) if params[:first_name].present?
      employee_details = employee_details.where(last_name:params[:last_name]) if params[:last_name].present?
      employee_details = employee_details.where(email:params[:email]) if params[:email].present?
      founder_details = founder_details.where(city:params[:city]) if params[:city].present?
      founder_details = founder_details.where(designation:params[:designation]) if params[:designation].present?
      founder_details = founder_details.where(first_name:params[:first_name]) if params[:first_name].present?
      founder_details = founder_details.where(last_name:params[:last_name]) if params[:last_name].present?
      founder_details = founder_details.where(email:params[:email]) if params[:email].present?

      render json:{
        company_detail:company,
        founder_details: founder_details,
        employee_details: employee_details
      }
    else

      render json:{success:false, message:"No Such company details present, Please enter valid company details"}, status:422
    end
  end


  def company_info
    begin
      company = CompanyDetail.find_by(name:params[:company_name], url:params[:url])
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
