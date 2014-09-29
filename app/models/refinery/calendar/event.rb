module Refinery
  module Calendar
    class Event < Refinery::Core::BaseModel
      extend FriendlyId

      friendly_id :title, :use => :slugged

      belongs_to :venue
      belongs_to :calendar

      validates :title, :presence => true, :uniqueness => true
      validates :calendar_id,   presence: true

      attr_accessible :title, :from, :to, :registration_link,
                      :venue_id, :excerpt, :description,
                      :featured, :position, :calendar_id

      alias_attribute :from, :starts_at
      alias_attribute :to, :ends_at

      delegate :name, :address,
                :to => :venue,
                :prefix => true,
                :allow_nil => true

      delegate :title, :to => :calendar, :prefix => true, :allow_nil => true

      scope :starting_on_day, lambda {|day| where(starts_at: day.beginning_of_day..day.end_of_day) }
      scope :ending_on_day, lambda {|day| where(ends_at: day.beginning_of_day..day.end_of_day) }

      scope :on_day, lambda {|day|
        where(
          arel_table[:starts_at].in(day.beginning_of_day..day.end_of_day).
          or(arel_table[:ends_at].in(day.beginning_of_day..day.end_of_day)).
          or( arel_table[:starts_at].lt(day.beginning_of_day).and(arel_table[:ends_at].gt(day.end_of_day)) )
        )
      }

      def is_on_day?(day)
        bod = day.beginning_of_day
        eod = day.end_of_day

        starts_at.present? &&
            ((starts_at >= bod && starts_at <= eod) ||
            (ends_at.present? && (
              (ends_at >= bod && ends_at <= eod) ||
              (starts_at < bod && ends_at > eod)
            )))
      end

      class << self
        def upcoming
          where('refinery_calendar_events.starts_at >= ?', Time.now)
        end

        def current_and_upcoming
          where("#{table_name}.ends_at >= ? OR #{table_name}.starts_at >= ?", Time.now, Time.now).order("#{table_name}.starts_at ASC")
        end

        def featured
          where(:featured => true)
        end

        def archive
          where('refinery_calendar_events.starts_at < ?', Time.now)
        end

        def in_calendars(calendars)
          where('refinery_calendar_events.calendar_id IN (?)', calendars.map(&:id) << -1)
        end

      end
    end
  end
end
