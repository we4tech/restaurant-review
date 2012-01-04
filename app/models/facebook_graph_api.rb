require 'json'
require 'open-uri'
require 'rest_client'
require 'timeout'

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
    response = post_request(:checkin, uid, params)
    if response.is_a?(Hash) && response["id"]
      response["id"]
    else
      nil
    end
  end

  def create_comment(uid, params)
    uid = @uid if uid.nil?
    response = post_request(:comment, uid, params)
    if response.is_a?(Hash) && response['id']
      response['id']
    else
      nil
    end
  end

  def find_nearby_places(options = {})
    result = send_request(:search, nil, options.merge(:type => 'place'))
    ["data"].present? ? result["data"] : []
  end

  class << self
    def display_picture(fb_uid, size = 'square')
      "#{FB_GRAPH_BASE_URI}#{fb_uid}/picture?size=#{size}"
    end
  end

  private
    def post_request(type, uid, params)
      params[:access_token] = URI.encode(@access_token)
      url = build_url(type, uid, params)
      response = ''

      Timeout::timeout 10 do
        response = RestClient.post(url, params.merge(:access_token => URI.encode(@access_token)))
      end
      JSON.load(response.to_str)
    end

    def send_request(type, uid, params = {})
      url = build_url(type, uid, params)
      #raise "RestClient.get \"#{url}\""
      response = RestClient.get url
      JSON.load(response.to_str)
    end

    def build_user_ref(uid)
      "#{FB_GRAPH_BASE_URI}#{uid ? "#{uid}/" : ''}"
    end

    def build_url(type, uid, params = nil)
      url = ''

      case type
        when :user
          url << build_user_ref(uid)
          url << "?access_token=#{URI.encode(@access_token)}"
          url << '&' + params.map{|k, v| "#{k}=#{URI.encode(v.to_s)}"}.join('&') if params

        when :friends
          url << build_user_ref(uid)
          url << "friends"
          url << "?access_token=#{URI.encode(@access_token)}"
          url << '&' + params.map{|k, v| "#{k}=#{URI.encode(v.to_s)}"}.join('&') if params

        when :checkin
          url << build_user_ref(uid)
          url << 'checkins'
          url << "?access_token=#{URI.encode(@access_token)}"
          url << '&' + params.map{|k, v| "#{k}=#{URI.encode(v.to_s)}"}.join('&') if params

        when :search
          url << build_user_ref(uid)
          url << 'search'
          url << "?access_token=#{URI.encode(@access_token)}"
          url << '&' + params.map{|k, v| "#{k}=#{URI.encode(v.to_s)}"}.join('&') if params

        when :comment
          if params.include? :checkin_id
            url << "#{FB_GRAPH_BASE_URI}"
            url << params.delete(:checkin_id) << '/comments'
            url << "?access_token=#{URI.encode(@access_token)}"
          end
      end
    end

end