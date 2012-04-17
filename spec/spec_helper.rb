$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'active_record'
require 'destroyer'

RSpec.configure do |config|
  config.before do
    ActiveRecord::Base.connection.execute("DELETE FROM users")
    ActiveRecord::Base.connection.execute("DELETE FROM posts")
    ActiveRecord::Base.connection.execute("DELETE FROM comments")
    ActiveRecord::Base.connection.execute("DELETE FROM avatars")
    ActiveRecord::Base.connection.execute("DELETE FROM categories_posts")
  end
end

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

ActiveRecord::Schema.define(:version => 0) do
  create_table :users, :force => true do |t|
  end
  create_table :categories, :force => true do |t|
  end
  create_table :posts, :force => true do |t|
    t.integer :user_id
  end
  create_table :categories_posts, :force => true do |t|
    t.integer :category_id
    t.integer :post_id
  end
  create_table :comments, :force => true do |t|
    t.integer :post_id
  end
  create_table :avatars, :force => true do |t|
    t.integer :user_id
  end
  create_table :avatar_histories, :force => true do |t|
    t.integer :avatar_id
  end
  create_table :chairs, :force => true do |t|
    t.integer :comment_id
  end
end