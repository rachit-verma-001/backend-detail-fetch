class CompanyDetail < ApplicationRecord
  has_many :employee_details, dependent: :destroy

  def employees_data
    employee_details.employees_data
  end

  def founders_data
    employee_details.founders_data
  end
end
