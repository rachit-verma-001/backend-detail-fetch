class EmployeeDetail < ApplicationRecord
  belongs_to :role
  belongs_to :company_detail


  def self.founders_data
    where(role:Role.find_by(name:"Founder"))
  end
  def self.employees_data
    where(role:Role.find_by(name:"Employee"))
  end
end
