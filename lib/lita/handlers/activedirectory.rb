module Lita
  module Handlers
    class Activedirectory < Handler
      namespace 'Activedirectory'
      config :host, required: true, type: String
      config :port, required: true, type: Integer, default: 389
      config :basedn, required: true, type: String
      config :user_basedn, required: true, type: String
      config :username, required: true, type: String
      config :password, required: true, type: String

      route(
        /(is)\s+(\S+)\s+(locked(\?)?)/i,
        :user_locked?,
        command: true,
        help: { t('help.user_locked?.syntax') => t('help.user_locked?.desc') }
      )

      route(
        /(unlock)\s+(\S+)/i,
        :unlock,
        command: true,
        help: { t('help.unlock.syntax') => t('help.unlock.desc') }
      )

      include ::Utils::Cratususer

      def user_locked?(response)
        user = response.matches[0][1]
        response.reply_with_mention(t('replies.user_locked?.working'))
        handle_user_query(user_query(user))
      end

      def handle_user_query(username)
        case username
        when true
          response.reply_with_mention(
            t('replies.user_locked?.locked', user: username)
          )
        when false
          response.reply_with_mention(
            t('replies.user_locked?.notlocked', user: username)
          )
        when nil
          response.reply_with_mention(
            t('replies.user_locked?.error', user: username)
          )
        end
      end

      def unlock
        user = response.matches[0][1]
        response.reply_with_mention(t('replies.unlock.working'))
        user_result = user_query(user)
        if user_result
          unlock_user(user)
        else
          handle_user_query(user_result)
        end
      end

      Lita.register_handler(self)
    end
  end
end
