# The single chat room. Messages are both sent (via #speak) and received
# over this channel's WebSocket connection.
class ChatChannel < ApplicationCable::Channel
  STREAM = "chat".freeze

  def self.broadcast_message(message)
    html = ApplicationController.render(partial: "messages/message", locals: { message: message })
    ActionCable.server.broadcast(STREAM, { html: html })
  end

  def subscribed
    stream_from STREAM
  end

  def speak(data)
    message = current_user.messages.new(body: data["body"])
    transmit({ error: message.errors.full_messages.to_sentence }) unless message.save
  end
end
