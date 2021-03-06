# == Schema Information
#
# Table name: version
#
#  id            :integer         not null, primary key
#  package_id    :integer
#  name          :string(255)
#  title         :string(255)
#  description   :string(255)
#  license       :string(255)
#  version       :string(255)
#  requires      :string(255)
#  depends       :string(255)
#  suggests      :string(255)
#  maintainer    :string(255)
#  author        :string(255)
#  url           :string(255)
#  date          :date
#  readme        :text
#  changelog     :text
#  news          :text
#  diff          :text
#  created_at    :datetime
#  updated_at    :datetime
#  maintainer_id :integer
#

class Version < ActiveRecord::Base
  belongs_to :package
  belongs_to :maintainer, :class_name => "Author"

  # def to_param
  #   version.gsub(".", "-")
  # end
  
  def urls
    (url.split(",") rescue []) + [cran_url]
  end
  
  def cran_url
    "http://cran.r-project.org/web/packages/#{name}"
  end
  
  def vname
    name + "_" + version
  end
  
  def depends
    parse_requirements(attributes["depends"])
  end

  def suggests
    parse_requirements(attributes["suggests"])
  end
  
  def parse_requirements(reqs)
    reqs.split(",").map{|full| full.split(" ")[0]}.map do |name|    
      Package.find_by_name name
    end.compact.sort_by{|v| v.name.downcase } rescue []
  end

  def cache_maintainer!
    author = Author.new_from_string(attributes["maintainer"])
    
    self.maintainer = author
    save
  end
    
end
