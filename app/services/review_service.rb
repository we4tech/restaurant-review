class ReviewService

  class Context
    attr_accessor :topic, :params, :user, :review, :host_instance

    def initialize(attrs = { })
      attrs.each do |k, v|
        self.send :"#{k}=", v
      end
    end

    def subscribe(instance)
      self.host_instance = instance
      self
    end

    def build
      self.user   = _find_user

      if self.user
        self.review = _new_review
      end

      self
    end

    def create
      self.build

      if self.review && self.review.save
        self._notify(:after_successfully_created)
      else
        self._notify(:after_failed_to_create)
      end
    end

    def _notify(method, *args)
      self.host_instance.send(method, *([self] + args))
    end

    private

    def _new_review
      Review.new(self.params.except(:session, :user, :user_id)).tap do |review|
        review.user_id  = self.user.id
        review.topic_id = self.topic.id
      end
    end

    def _find_user
      if self.host_instance.send(:logged_in?)
        self.host_instance.send(:current_user)

      elsif _credential_given?
        _signin_user

      elsif _new_user_given?
        _signup_user
      end
    end

    def _signup_user
      _user = User.create(params[:user])
      if _user.valid?
        _notify(:after_user_signed_in, _user)
        _user
      else
        nil
      end
    end

    def _signin_user
      _session = Session.new(params[:session])
      _session.authenticate.get_user.tap do |_user|
        _notify(:after_user_signed_in, _user) if _user.present?
      end
    end

    def _credential_given?
      params[:session].present? &&
          params[:session][:login].present? &&
          params[:session][:password].present?
    end

    def _new_user_given?
      params[:user].present? &&
          params[:user][:email].present? &&
          params[:user][:login].present? &&
          params[:user][:password].present? &&
          params[:user][:password_confirmation].present?
    end
  end


  class << self
    def create_from_params(topic, review_params)
      Context.new(:topic => topic, :params => review_params)
    end
  end
end