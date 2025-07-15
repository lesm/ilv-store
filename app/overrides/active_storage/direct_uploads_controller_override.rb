# frozen_string_literal: true

ActiveStorage::DirectUploadsController.class_eval do
  before_action :require_authentication
  before_action :authorize_admin!

  def require_authentication
    resume_session || render(status: :unauthorized, json: { error: 'Authentication required' })
  end

  def resume_session
    Current.session ||= find_session_by_cookie
  end

  def find_session_by_cookie
    Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
  end

  def authorize_admin!
    return if Current.user.admin?

    render(status: :unauthorized, json: { error: 'Authentication required' })
  end
end
