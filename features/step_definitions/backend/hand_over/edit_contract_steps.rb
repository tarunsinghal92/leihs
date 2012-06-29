When /^I change the time range for all contract lines, envolving option and item lines$/ do
  step 'I add an option to the hand over by providing an inventory code and a date range'
  all(".line").each do |line|
    line.find(".select input").click
  end
  step 'I edit the timerange of the selection'
  @line = @hand_over.lines.first
  @old_start_date = @line.start_date
  @new_start_date = if @line.start_date + 1.day < Date.today
      Date.today
    else
      @line.start_date + 1.day
  end
  @new_start_date_element = get_fullcalendar_day_element(@new_start_date, @line)
  @new_start_date_element.click
  find("a", :text => "Start Date").click
  step 'I save the booking calendar'
end

Then /^the time range for all contract lines is changed$/ do
  @customer.visits.hand_over.detect{|x| x.lines.size > 1}.lines.each do |line|
    line.start_date.should == @new_start_date
  end
end

When /^I change the time range for that option$/ do
  @option_line = @customer.visits.collect(&:lines).flatten.detect{|x| x.is_a?(OptionLine)}
  find(".option_line", :text => @option_line.option.name).find(".button", :text => "Edit").click
  @new_start_date = change_line_start_date(@option_line, 2)
end

Then /^the time range for that option line is changed$/ do
  @option_line.reload.start_date.should == @new_start_date
end