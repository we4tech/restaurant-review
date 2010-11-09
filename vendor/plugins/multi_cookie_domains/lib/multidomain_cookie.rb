# Extend cookie store
ActionController::Session::CookieStore.class_eval do
  alias_method :__build_cookie, :build_cookie
  @@override_domain = nil
  cattr_accessor :override_domain

  def build_cookie(key, value)
    if @@override_domain
      value[:domain] = @@override_domain
    end

    __build_cookie(key, value)
  end
end

ActionController::Session::AbstractStore.class_eval do
  alias_method :__call, :call
  @@override_domain = nil
  cattr_accessor :override_domain

  def call(env)
    response = __call(env)
    headers = response[1]
    override_cookie_header(headers)

    response
  end

  def override_cookie_header(headers)
    existing_cookie_header = headers[ActionController::Session::AbstractStore::SET_COOKIE]
    if existing_cookie_header && @@override_domain
      headers[ActionController::Session::AbstractStore::SET_COOKIE] =
          existing_cookie_header.gsub(/domain=([\.\w]+);/, 'domain=' + @@override_domain + ';')
    end
  end
end