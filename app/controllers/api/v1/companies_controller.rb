class Api::V1::CompaniesController < ApplicationController
  before_action :get_company, only: [:destroy, :show, :update, :resyncing]

  def create
    cparams = company_params

    cparams[:foundation_year]=Date.parse(params[:foundation_year]).year if params[:foundation_year].present?
    company = CompanyDetail.create!(cparams)
    render json:{success:true, company:company}
  end


  def resyncing
    @company.update(resync_progress:params[:resync_progress])
    render json:{status:@company.resync_progress, companies:
      ActiveModelSerializers::SerializableResource.new(CompanyDetail.all, each_serializer: Api::V1::CompaniesSerializer)}
  end

  def index
    companies = CompanyDetail.all
    # companies = CompanyDetail.all&.order(created_at: :desc)
    render json:{success:true, companies:
      ActiveModelSerializers::SerializableResource.new(companies, each_serializer: Api::V1::CompaniesSerializer)}
  end


  def sync
    companies = CompanyDetail.where.not(id:params[[:id]])
    companies&.update(resync_progress:params[:resync_progress]) if params[:resync_progress]
    render json:{companies: CompanyDetail.all, success:true}
  end


  def destroy
    if @company.destroy
      render json:{success:true, message:"company deleted succcessfully"}
    else
      render json:{success:false, message:"Something went wrong"}
    end
  end

  def show
    ppage = params[:page].present? ? params[:page] : CompanyDetail::PAGE
    pppage = params[:per_page].present? ? params[:per_page] : CompanyDetail::PER_PAGE
    all_employee_details = @company.employees_data
    employee_details = all_employee_details.paginate(page: ppage, per_page: pppage )
    if employee_details.present? && pppage.present?
      mod = all_employee_details.count % pppage.to_i
      pages = all_employee_details.count / pppage.to_i
      pages += 1 if mod > 0
    else
      pages = 0
    end
    render json:{
      company: @company,
      employee_details: employee_details,
      founders_details: @company.founders_data,
      pagination: {
        current_page: employee_details.current_page,
        next_page: employee_details.next_page,
        # prev_page: employee_details.prev_page,
        total_pages: pages.present? ? pages : '',
        total_count: all_employee_details.count
        #total_count: products.total_count
      }
    }
  end

  def destroy_all
    if CompanyDetail.all.destroy_all
      render json:{success:true, message:"All companies deleted successfully"}
    else
      render json:{success:false, message:"Something went wrong"}
    end
  end


  def update
    if @company.update(company_params)
      render json:{success:true, message:"Data Updated Successfully", company:@company}
    else
      render json:{success:false, message:"Something went wrong"}
    end

  end

  private

  def company_params
    params.permit(:name,:url,:company_type,:foundation_year, posts:[])
  end

  def get_company
    @company = CompanyDetail.find(params[:id])
  end

end
