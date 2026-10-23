class ChatController < ApplicationController
  def show
    @messages = Message.history
  end
end
