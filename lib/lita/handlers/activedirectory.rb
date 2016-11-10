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
        handle_user_query(response, user, user_query(user))
      end

      def unlock(response)
        user = response.matches[0][1]
        response.reply_with_mention(t('replies.unlock.working'))
        user_result = user_query(user)
        if user_result
          handle_unlock_query(response, user, unlock_user(user))
        else
          handle_user_query(response, user, user_result)
        end
      end

      private

      def handle_user_query(response, user, result)
        case result
        when true
          response.reply_with_mention(
            t('replies.user_locked?.locked', user: user)
          )
        when false
          response.reply_with_mention(
            t('replies.user_locked?.notlocked', user: user)
          )
        when nil
          response.reply_with_mention(
            t('replies.user_locked?.error', user: user)
          )
        end
      end

      def handle_unlock_query(response, user, result)
        case result
        when true
          response.reply_with_mention(
            t('replies.unlock.success', user: user)
          )
        when false
          response.reply_with_mention(
            t('replies.unlock.fail', user: user)
          )
        end
      end

      Lita.register_handler(self)
    end
  end
end
