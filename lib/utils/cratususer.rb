module Utils
  # piggy back on cratus for ldap work
  module Cratususer
    def user_query(username)
      options = {
        host: config.host,
        port: config.port,
        base: config.basedn,
        auth: {
          method: :simple,
          username: config.username,
          password: config.password
        }
      }
      Cratus::Config.merge(options)
      Cratus::LDAP.connect
      user = Cratus::User.new(username.to_s)
      user ? user.locked? : user
    end
  end
end
