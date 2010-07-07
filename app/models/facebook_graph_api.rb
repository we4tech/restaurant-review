require 'json'
require 'open-uri'

class FacebookGraphApi

  attr_accessor :access_token, :uid
  FB_GRAPH_BASE_URI = 'https://graph.facebook.com/'

  def initialize(access_token, uid)
    @access_token = access_token
    @uid = uid
  end

  def find_user(uid = nil)
    uid = @uid if uid.nil?
    send_request :user, uid
  end

  def find_friends(uid = @uid)
    uid = @uid if uid.nil?
    send_request :friends, uid
  end

  class << self
    def display_picture(fb_uid, size = 'square')
      "#{FB_GRAPH_BASE_URI}#{fb_uid}/picture?size=#{size}"
    end
  end

  private
    def send_request(type, uid)
      url = build_url(type, uid)
      json_text = nil

      open(url) do |response|
        json_text = response.read
      end

      JSON.load(json_text)
    end

    def build_url(type, uid)
      url = "#{FB_GRAPH_BASE_URI}#{uid}/"

      case type
        when :user
        url << ""

        when :friends
        url << "friends"
      end

      url << "?access_token=#{URI.encode(@access_token)}"
    end

end