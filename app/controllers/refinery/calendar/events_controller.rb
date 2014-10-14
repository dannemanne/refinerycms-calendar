module Refinery
  module Calendar
    class EventsController < ::ApplicationController
      before_filter :find_page,           except: [:archive, :new, :create]
      before_filter :auth_or_create_cal,  only: :create


      helper_method :personal_calendars

      def new
        @event = ::Refinery::Calendar::Event.new(params[:event])
        @venues = ::Refinery::Calendar::Venue.order('name')
      end

      def create
        @event = @calendar.events.build(params[:event])
        if @event.save
          flash[:notice] = 'Event successfully created'
        else
          flash[:alert] = 'Failed to create Event'
        end
        redirect_to refinery.calendar_events_path
      end

      def index
        @calendars = ::Refinery::Calendar::Calendar.visible_for_user(current_refinery_user)
        @active_calendars = ::Refinery::Calendar::Calendar.active_for_user(current_refinery_user)
        @events = ::Refinery::Calendar::Event.in_calendars(@calendars).includes(:calendar).order('refinery_calendar_events.starts_at DESC')

        # you can use meta fields from your model instead (e.g. browser_title)
        # by swapping @page for @event in the line below:
        present(@page)
      end

      def show
        @event = ::Refinery::Calendar::Event.find(params[:id])

        # you can use meta fields from your model instead (e.g. browser_title)
        # by swapping @page for @event in the line below:
        present(@page)
      end

      def archive
        @events = ::Refinery::Calendar::Event.archive.order('refinery_calendar_events.starts_at DESC')
        render :template => 'refinery/calendar/events/index'
      end

      protected
      def find_page
        @page = ::Refinery::Page.where(:link_url => "/calendar/events").first
      end

      def personal_calendars
        @personal_calendars ||= ::Refinery::Calendar::Calendar.where(user_id: current_refinery_user.id)
      rescue StandardError
        []
      end

      def auth_or_create_cal
        if params[:event]
          if params[:event][:calendar_id]
            cal_id = params[:event].delete(:calendar_id).to_i
            @calendar = personal_calendars.detect { |c| c.id == cal_id }
          elsif params[:event][:new_calendar_title]
            @calendar = ::Refinery::Calendar::Calendar.create(
                title: params[:event].delete(:new_calendar_title),
                private: params[:event].delete(:private),
                user_id: current_refinery_user.id,
                activate_oc_create: '1')
          end
        end
      end

    end
  end
end
