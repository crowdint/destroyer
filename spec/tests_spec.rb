require 'spec_helper'
require 'models'
require 'active_support'

ActiveRecord::Base.logger = ActiveSupport::BufferedLogger.new(STDOUT)

categories = [Category.create, Category.create]

describe Destroyer do
  describe "methods" do
    it "adds destroyer method to ActiveRecord::Base" do
      ActiveRecord::Base.public_methods.include?(:destroyer).should be_true
    end
    it "adds has_one_with_destroy method to ActiveRecord::Base" do
      ActiveRecord::Base.public_methods.include?(:has_one_with_destroy).should be_true
    end
    it "adds has_many_with_destroy method to ActiveRecord::Base" do
      ActiveRecord::Base.public_methods.include?(:has_many_with_destroy).should be_true
    end
  end

  context "has_one_with_destroy" do
    describe "User" do
      it "returns [Avatar]" do
        User.has_one_with_destroy.should == [Avatar]
      end
    end
    describe "Avatar" do
      it "returns []" do
        Avatar.has_one_with_destroy.eql?([]).should be_true
      end
    end
    describe "Category" do
      it "returns []" do
        Category.has_one_with_destroy.empty?.should be_true
      end
    end
  end

  context "has_many_with_destroy" do
    describe "User" do
      it "returns [Post]" do
        User.has_many_with_destroy.eql?([Post]).should be_true
      end
    end
    describe "Category" do
      it "returns []" do
        Category.has_many_with_destroy.empty?.should be_true
      end
    end
    describe "Post" do
      it "returns [Comment]" do
        Post.has_many_with_destroy.eql?([Comment]).should be_true
      end
    end
  end

  context "has_many_through_with_destroy" do
    describe "Post" do
      it "returns [CategoriesPost]" do
        Post.has_many_through_with_destroy.eql?([CategoriesPost]).should be_true
      end
    end
    describe "Category" do
      it "returns []" do
        Category.has_many_with_destroy.empty?.should be_true
      end
    end
  end

  context "destroyer in action" do
    before do
      # five Users and one Avatar per user
      # two posts per user = ten posts
      # three comments per post = thirty comments
      5.times do
        user = User.create(:avatar => Avatar.create(:avatar_history => AvatarHistory.create))
        2.times do
          post = Post.create(:user => user, :categories => [categories[rand(2)]])
          3.times do
            Chair.create(:comment => Comment.create(:post => post))
          end
        end
      end
    end

    context "has_hone relationships" do
      describe "default block" do
        it "destroys one user and its avatar" do
          User.start_destroyer

          User.count.should be(4)
          Avatar.count.should be(4)
        end
      end

      describe "passing a new block" do
        it "destroys the users with the ids given in the block, and also destroys their avatar" do
          users_to_destroy = User.first(2)
          user_ids = users_to_destroy.map(&:id)
          avatars_to_destroy = Avatar.where(["user_id IN (?)", user_ids])

          User.destroyer( lambda { user_ids })
          User.start_destroyer

          User.count.should be(3)
          Avatar.count.should be(3)

          User.all.map(&:id).any? {|id| user_ids.include?(id)}.should be_false
          Avatar.all.map(&:id).any? {|id| avatars_to_destroy.map(&:id).include?(id)}.should be_false
        end

        describe "when the second time a new block is not given" do
          it "destroys also the first User and its Avatar" do
            first_user = User.first(:include => :avatar)
            last_user = User.last(:include => :avatar)

            User.destroyer( lambda { [User.last] } )
            User.start_destroyer

            User.start_destroyer

            User.all.any? {|user| [first_user.id, last_user.id].include?(user.id) }.should be_false
            Avatar.all.any? {|avatar| [first_user.avatar.id, last_user.avatar.id].include?(avatar.id) }.should be_false
          end
        end
      end
    end

    context "has_many through" do
      describe "default block" do
        it "destroys one post and its comments" do
          Post.start_destroyer

          Post.count.should == 9
          Comment.count.should == 27
        end
        it "destroys one record in the categories_posts table, and does not removes any Category" do
          Post.start_destroyer

          Post.count.should == 9
          CategoriesPost.count.should == 9
          Category.count.should == 2
        end
      end
    end
  end
end