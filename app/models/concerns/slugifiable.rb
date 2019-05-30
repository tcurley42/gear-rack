module Slugifiable

  module InstanceMethods
    def slug
      self.name.gsub(" ", "-").downcase
    end
  end

  module ClassMethods
    def find_by_slug(slug)
      self.all.each do |s|
        if slug == s.slug
          break s if slug == s.slug
        end
      end
    end
  end
end