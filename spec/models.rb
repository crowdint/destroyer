class User < ActiveRecord::Base
  has_one :avatar, :dependent => :destroy
  has_many :posts, :dependent => :destroy
  has_one :avatar_history, :through => :avatar

  destroyer lambda { [select("id").first] }
end

class Category < ActiveRecord::Base
  has_many :categories_posts
  has_many :posts, :through => :categories_posts
end

class CategoriesPost < ActiveRecord::Base
  belongs_to :category
  belongs_to :post
end

class Post < ActiveRecord::Base
  belongs_to :user

  has_many :categories_posts
  has_many :categories, :through => :categories_posts, :dependent => :destroy, :class_name => "Category"
  has_many :comments, :dependent => :destroy

  destroyer lambda { [select("id").first] }
end

class Comment < ActiveRecord::Base
  belongs_to :post
  has_one :chair, :dependent => :destroy
end

class Chair < ActiveRecord::Base
  belongs_to :comment
end

class Avatar < ActiveRecord::Base
  belongs_to :user
  has_one :avatar_history
end

class AvatarHistory < ActiveRecord::Base
  belongs_to :avatar
end