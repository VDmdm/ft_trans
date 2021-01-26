class NotificationRelayJob < ApplicationJob
  queue_as :default

  def perform(notification)
    html = ApplicationController.render partial: "events/#{notification.notifiable_type}/#{notification.action}", locals: {notification: notification}, formats: [:html]
    ActionCable.server.broadcast "notifications:#{notification.recipient_id}", html: html
  end
end