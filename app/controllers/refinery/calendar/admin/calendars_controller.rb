module Refinery
  module Calendar
    module Admin
      class CalendarsController < ::Refinery::AdminController

        crudify :'refinery/calendar/calendar',
                :title_attribute => 'title',
                :xhr_paging => true,
                :sortable => false,
                :order => 'created_at DESC'
      end
    end
  end
end
