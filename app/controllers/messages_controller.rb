class MessagesController < ApplicationController

  before_filter :login_required, :except => [:show, :index]

  def index
    @restaurant = Restaurant.find(params[:restaurant_id].to_i)
    @messages = @restaurant.messages
    @site_title = 'News'
    render_view 'messages/index'
  end

  def show
    @restaurant = Restaurant.find(params[:restaurant_id].to_i)
    @message = Message.find(params[:id].to_i)
    @premium_template = @restaurant.selected_premium_template
    @context = :inner_page

    render_view 'messages/show'
  end

  def new
    @restaurant = Restaurant.find(params[:restaurant_id].to_i)
    @message = Message.new
    @message_types = Message::TYPES

    render_view 'messages/new'
  end

  def create
    @restaurant = Restaurant.find(params[:message][:restaurant_id].to_i)

    if_permits?(@restaurant) do
      @message = Message.new(params[:message])
      @message.restaurant_id = @restaurant.id
      @message.user_id = current_user.id
      @message.topic_id = @topic.id

      if @message.save
        notify :success, restaurant_messages_path(@restaurant)
      else
        @message_types = Message::TYPES
        render_view 'messages/new'
      end
    end
  end

  def edit
    @restaurant = Restaurant.find(params[:restaurant_id].to_i)
    @message = Message.find(params[:id].to_i)
    @message_types = Message::TYPES

    render_view 'messages/edit'
  end

  def update
    @message = Message.find(params[:id].to_i)
    @restaurant = @message.restaurant

    if_permits?(@message) do
      attributes = params[:message]
      attributes.delete(:user_id)
      attributes.delete(:topic_id)
      attributes.delete(:restaurant_id)

      if @message.update_attributes(attributes)
        notify :success, restaurant_messages_path(@restaurant)
      else
        @message_types = Message::TYPES
        render_view 'messages/edit'
      end
    end
  end

  def destroy
    @message = Message.find(params[:id].to_i)
    if_permits?(@message) do
      if @message.destroy
        notify :success, restaurant_messages_path(@message.restaurant.id)
      else
        notify :failure, restaurant_messages_path(@message.restaurant.id) 
      end
    end
  end

end
