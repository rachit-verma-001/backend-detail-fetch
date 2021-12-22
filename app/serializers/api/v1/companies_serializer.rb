# frozen_string_literal: true

class Api::V1::CompaniesSerializer < ActiveModel::Serializer
  attributes :id, :name, :posts, :foundation_year, :tagline, :city, :followers, :no_of_employees, :logo, :url, :company_type, :resync_progress

  def posts
    object.posts.class == Array ? object.posts&.join(", ")&.downcase : object.posts
  end

end
