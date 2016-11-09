module Lita
  module Handlers
    class Activedirectory < Handler
      namespace 'Activedirectory'
      config :host, required: true, type: String
      config :port, required: true, type: Integer, default: '389'
      config :basedn, required: true, type: String
      config :username, required: true, type: String
      config :password, required: true, type: String

      route(
        /(is)\s+(\S+)\s+(locked(\?)?)/i,
        :user_locked?,
        command: true,
        help: { t('help.user_locked?.syntax') => t('help.user_locked?.desc') }
      )

      include ::Utils::Cratususer

      def user_locked?(response)
        user = response.matches[0][1]
        response.reply_with_mention(t('replies.user_locked?.working'))
        case user_query(user)
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

      Lita.register_handler(self)
    end
  end
end
