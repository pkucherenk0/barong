# frozen_string_literal: true

module Barong
  # admin activities log writer class
  class ActivityLogger
    ACTION = { post: 'create', put: 'update', get: 'list', delete: 'delete' }.freeze

    def write(options = {})
      @activities ||= Queue.new
      @activities.push(options)

      @thread ||= Thread.new do
        loop do
          msg = @activities.pop
          Activity.create!(format_params(msg))
        end
      rescue
        Rails.logger.error { "Failed to create activity: #{$!}" }
        Rails.logger.error { $!.backtrace.join("\n") }
      end
    end

    def format_params(params)
      topic = params[:topic].nil? ? params[:path].split('/admin/')[1].split('/')[0] : params[:topic]
      {
        admin_uid:  params[:admin_uid],
        user_uid:   params[:admin_uid],
        user_ip:    params[:user_ip],
        user_agent: params[:user_agent],
        topic:      topic,
        action:     ACTION[params[:verb].downcase.to_sym],
        result:     params[:result]
      }
    end
  end
end
