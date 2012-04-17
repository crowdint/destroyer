#Destroyer

Deletes records(without instantiating the records first) based on a block(which returns an array of ids) given and also recursively deletes all their associated records if they are marked as :dependent => :destroy. It is useful for background processing.

## Installing

Add this to your `Gemfile`

    gem 'destroyer'

##How to use it

Add `destroyer` with a `lambda` or `Proc` to the model you want to delete records from which returns an array of ids, like this:

    class User < ActiveRecord::Base
      destroyer lambda { select("id").where(['created_at < ?', Time.now])] }
    end

Then, whenever you want to delete the records just call `start_destroyer` on your model, like this:

    User.start_destroyer

You could also send a new block to `destroyer` method:

    User.destroyer( lambda { User.select('id').where('rol_id = 4') })

And then, just call `start_destroyer` on the model and it will execute the process with the block that you just passed to `destroyer` method, keep in mind that the original block will not be overwritten, but be sure to execute `start_destroyer` whenever you pass a new block, otherwise this block will be present(because Destroyer uses class instance variables) the next time you call `start_destroyer` and it will try to delete the records with the ids given in the block, or make sure to set `destroyer_block` to `nil` on the model, like this:

  User.destroyer_block = nil

##Notes

`destroyer` also accepts a hash of options, the only available option is `batch_size`, it is used to delete all records in batches, by default is 1000, make sure to set it to and empty hash if you modified the value and did not call `start_destroyer`, otherwise it will have the last value the next time you call the `start_destroyer` method.

If you do not specify a default block, and later in the code you call your Model.destroyer with a block, that block will become the default block.


##Example

    class PurchaseOrder < ActiveRecord::Base
      has_many :line_items, :dependent => :destroy
      destroyer lambda { select("id").where(["state = 'deleted' AND created_at < ?", 1.month.ago]) }
    end

    class LineItem < ActiveRecord::Base
      has_many :variant_line_items
      belongs_to :purchase_order
    end

    class VariantLineItem < ActiveRecord::Base
      belongs_to :line_item
    end

    PurchaseOrder.start_destroyer

And that code is going to delete all purchase orders which 'state' is 'deleted' and are older that one month ago, and it will also delete all its related line items as well as all their variant line items.