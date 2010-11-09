module MultidomainCookieHelper

  def set_cookie_domain(p_host = nil)
    host = p_host || request.host
    host_parts = host.split(/\./)
    host = host_parts[(host_parts.length - 2)..(host_parts.length)].join('.')
    ActionController::Session::CookieStore.override_domain = ".#{host}"
    ActionController::Session::AbstractStore.override_domain = ".#{host}"
  end
end