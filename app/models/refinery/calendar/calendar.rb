module Refinery
  module Calendar
    class Calendar < Refinery::Core::BaseModel
      belongs_to :user,     class_name: '::Refinery::User'
      has_many :user_calendars,   dependent: :destroy
      has_many :users,            through: :user_calendars

      attr_accessor :activate_on_create

      attr_accessible :default_rgb_code, :private, :activate_on_create, :user_id, :function, :title, :position

      validates :title, presence: true, uniqueness: { scope: [:user_id] }
      validates :function,  uniqueness: true, allow_blank: true

      after_create do
        if activate_on_create
          unless private
            ::Refinery::User.all.each do |user|
              self.users << user
            end
          end
        end
      end

      def uniq_name
        if user.present?
          "#{title} (#{ user.full_name })"
        elsif function.present?
          "#{title} (#{ function })"
        else
          title
        end

      end


      class << self
        def active_for_user(user)
          joins(:user_calendars).where(refinery_calendar_user_calendars: { user_id: user.try(:id), inactive: false })
        end
      end

    end
  end
end
