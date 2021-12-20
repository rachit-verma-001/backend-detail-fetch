class CompanyDetail < ApplicationRecord
  has_many :employee_details, dependent: :destroy

  validates_presence_of :name,:company_type,:url
  validates_uniqueness_of :url

  before_save :add_default_progress

  PAGE = 1
  PER_PAGE = 10

  def add_default_progress


    self.resync_progress = "Not Synced" unless resync_progress?


  end

  def employees_data
    # employee_details.employees_data
    employee_details
  end

  def founders_data
    employee_details.founders_data
  end
end
