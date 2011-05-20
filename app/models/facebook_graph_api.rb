require 'json'
require 'open-uri'
require 'rest_client'

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

  def check_in(uid, params)
    uid = @uid if uid.nil?
    raise post_request(:checkin, uid, params).inspect
  end

  class << self
    def display_picture(fb_uid, size = 'square')
      "#{FB_GRAPH_BASE_URI}#{fb_uid}/picture?size=#{size}"
    end
  end

  private
    def post_request(type, uid, params)
      params[:access_token] = URI.encode(@access_token)
      url = build_url(type, uid)
      puts "RestClient.post \"#{url}\", #{params.inspect}"
      response = RestClient.post(url, params)
      raise response.inspect
      JSON.load(response.to_str)
    end

    def send_request(type, uid)
      url = build_url(type, uid)
      response = RestClient.get url
      JSON.load(response.to_str)
    end

    def build_url(type, uid)
      url = "#{FB_GRAPH_BASE_URI}#{uid}/"

      case type
        when :user
        url << ""

        when :friends
        url << "friends"

        when :checkin
        url << 'checkins'
      end

      url << "?access_token=#{URI.encode(@access_token)}"
    end

end