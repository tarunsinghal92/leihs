module Availability
  module DocumentLine

    attr_accessor :allocated_group_id
    
#################################
    
    def available?
      #tmp#1 doesn't work for tests
      av = if end_date < Date.today # check if it was never handed over
        false
      elsif is_a?(OrderLine) and order.status_const == Order::UNSUBMITTED
        # the user's unsubmitted order_lines should exclude each other
        all_quantities = model.order_lines.scoped_by_inventory_pool_id(inventory_pool).unsubmitted.running(start_date).by_user(order.user).sum(:quantity)
        (maximum_available_quantity >= all_quantities)
      else
        # if an item is already assigned, but the start_date is in the future, we only consider the real start-end range dates
        aq = model.availability_in(inventory_pool).changes.between(start_date, end_date).values.flat_map{|x| x.values}
        aq.all? {|q| q[:out_document_lines] and q[:out_document_lines][self.class.to_s].try(:include?, id) ? q[:in_quantity] >= 0 : true }
      end

      # OPTIMIZE
      if av and is_a?(OrderLine)
        av = (av and inventory_pool.is_open_on?(start_date) and inventory_pool.is_open_on?(end_date)) 
        av = (av and not order.user.access_right_for(inventory_pool).suspended?) if order.user # OPTIMIZE why checking for user ??
      end
      
      return av
    end
    alias :is_available :available? # NOTE remove if custom as_json is gone 

    def maximum_available_quantity
      model.availability_in(inventory_pool).maximum_available_in_period_for_groups(group_ids, start_date, end_date)      
    end

  end
end
